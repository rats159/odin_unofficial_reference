package unofficial_reference_generator

import "core:fmt"
import "core:os"
import cmark "vendor:commonmark"

error :: proc(message: string, loc :=#caller_location) -> ! {
    fmt.eprintfln("[%s:%d:%d] %s", loc.file_path, loc.line, loc.column, message)
    os.exit(1)
}

or_error :: proc(val: $T, message: string) {
    if val != nil {
        error(message)
    }
}

main :: proc() {
    root_data := os.read_entire_file("root/index.md", context.allocator) or_else error("Failed to read root file")

    cmark_node := cmark.parse_document(raw_data(root_data),len(root_data),{})
    
    html := cmark.render_html(cmark_node, {})

    as_string := string(html)

    or_error(os.write_entire_file("out/index.html", transmute([]byte)(as_string)), "Failed to write root file")
}