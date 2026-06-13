package unofficial_reference_generator

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"
import cmark "vendor:commonmark"

base_html := #load("base.html", string)
base_css := #load("base.css", string)

error :: proc(message: string, loc := #caller_location) -> ! {
	fmt.eprintfln("[%s:%d:%d] %s", loc.file_path, loc.line, loc.column, message)
	os.exit(1)
}

or_error :: proc(val: $T, message: string) {
	if val != nil {
		error(message)
	}
}

cmark_iterator :: proc(iter: ^cmark.Iter) -> (^cmark.Node, cmark.Event_Type, bool) {
	res := cmark.iter_next(iter)
	if res == .Done {
		return {}, {}, false
	}

	return cmark.iter_get_node(iter), res, true
}

collect_text :: proc(node: ^cmark.Node) -> string {
	iter := cmark.iter_new(node)
	defer cmark.iter_free(iter)

	text: strings.Builder

	for node, direction in cmark_iterator(iter) {
		strings.write_string(&text, string(node.data[:node.len]))
	}

	for &ch in text.buf {
		switch ch {
		case ' ':
			ch = '-'
		case 'A' ..= 'Z':
			ch += 32
		}
	}

	return strings.to_string(text)
}

render_page :: proc(root: ^cmark.Node) -> string {
	iter := cmark.iter_new(root)
	builder: strings.Builder

	for node, direction in cmark_iterator(iter) {
		entering := direction == .Enter
		#partial switch node.type {
		case .Document: // pass
		case .List:
			if entering {
				fmt.sbprint(&builder, "<ul>")
			} else {
				fmt.sbprint(&builder, "</ul>")
			}
		case .Soft_Break:
			// what is this? cmark puts a space here
			fmt.sbprint(&builder, " ")
		case .Item:
			if entering {
				fmt.sbprint(&builder, "<li>")
			} else {
				fmt.sbprint(&builder, "</li>")
			}
		case .Emph:
			if entering {
				fmt.sbprint(&builder, "<em>")
			} else {
				fmt.sbprint(&builder, "</em>")
			}
		case .Code:
			assert(entering, "Code can't exit i think")
			fmt.sbprint(&builder, "<code>")
			fmt.sbprint(&builder, string(node.data[:node.len]))
			fmt.sbprint(&builder, "</code>")
		case .Code_Block:
			assert(entering, "Code blocks can't exit i think")
			fmt.sbprint(&builder, "<pre><code>")
			fmt.sbprint(&builder, string(node.data[:node.len]))
			fmt.sbprint(&builder, "</code></pre>")
		case .Link:
			if entering {
				fmt.sbprintf(&builder, "<a href=\"%s\">", node.as.link.url)
			} else {
				fmt.sbprint(&builder, "</a>")
			}
		case .Paragraph:
			if entering {
				fmt.sbprint(&builder, "<p>")
			} else {
				fmt.sbprint(&builder, "</p>")
			}
		case .Text:
			fmt.sbprint(&builder, string(node.data[:node.len]))
		case .Heading:
			heading_info := node.as.heading
			node_type := [2]u8{'h', '?'}
			node_type[1] = u8(heading_info.level) + '0'
			if entering {
				text := collect_text(node)
				fmt.sbprintf(&builder, "<%s id=\"%s\">", node_type, text)
			} else {
				fmt.sbprintf(&builder, "</%s>", node_type)
			}

		case:
			fmt.panicf("Unhandled node type '%s' for rendering", node.type)
		}
	}

	return strings.to_string(builder)
}

make_sidebar_rec :: proc(
	path, base_name: string,
	path_builder: ^strings.Builder,
	builder: ^strings.Builder,
) {
	file := os.open(path) or_else error("Failed to open path")
	iter := os.read_directory_iterator_create(file)

	index_path := filepath.join({path, "index.md"}) or_else error("Failed to join path")
	if os.exists(index_path) {
		fmt.sbprintfln(
			builder,
			"<a href=\"%s\">%s</a>",
			strings.to_string(path_builder^),
			base_name,
		)
	} else {
		fmt.sbprintfln(builder, "<span>%s</span>", base_name)
	}
	fmt.sbprintln(builder, "<ul>")
	for entry in os.read_directory_iterator(&iter) {
		if entry.type == .Directory {
			fmt.sbprintln(builder, "<li>")
			fmt.sbprintf(path_builder, "%s/", entry.name)
			make_sidebar_rec(entry.fullpath, entry.name, path_builder, builder)
			resize(&path_builder.buf, len(path_builder.buf) - len(entry.name) - 1)
			fmt.sbprintln(builder, "</li>")
		} else if entry.name != "index.md" {
			fmt.eprintfln("Warn: Non-index.d file inside markdown source: %s", entry.fullpath)
		}
	}
	fmt.sbprintln(builder, "</ul>")
}

make_sidebar :: proc(path: string) -> string {
	document_builder: strings.Builder
	path_builder: strings.Builder

	strings.write_string(&path_builder, "/")

	make_sidebar_rec(path, "Home", &path_builder, &document_builder)

	return strings.to_string(document_builder)
}

main :: proc() {
	sidebar := make_sidebar("root/Home")
	walker := os.walker_create("root")

	absolute_dir := filepath.abs("./root") or_else error("Failed to get absolute path of root dir")

	for file in os.walker_walk(&walker) {
		if file.type == .Directory {
			continue
		}
		relative_path :=
			filepath.rel(absolute_dir, file.fullpath) or_else error(
				"Failed to get path relative to root",
			)
		relative_to_root :=
			filepath.join({"root", relative_path}) or_else error("Failed to join paths")
		root_data :=
			os.read_entire_file(relative_to_root, context.allocator) or_else error(
				"Failed to read file",
			)

		assert(filepath.ext(relative_path) == ".md", "Non markdown file in markdown directory")
		out_file_name := strings.concatenate(
			{"./out/", relative_path[:len(relative_path) - 3], ".html"},
		)
		assert(filepath.ext(out_file_name) == ".html", "Screwed up changing the file extension")


		cmark_node := cmark.parse_document(raw_data(root_data), len(root_data), {})

		html := render_page(cmark_node) //cmark.render_html(cmark_node, {})

		as_string := string(html)

		path_to_file := filepath.dir(out_file_name)
		// fmt.println(out_file_name)

		page := fmt.aprintf(base_html, base_css, sidebar, as_string)

		or_error(os.make_directory_all(path_to_file), "Failed to make directories")
		or_error(os.write_entire_file(out_file_name, page), "Failed to write file")
	}
}

