# Unofficial Odin Reference
This is the repository for my unofficial Odin reference.

## Building the website
The HTML is generated from Markdown files, stored at `root`. You should just be able to run `odin run .` to generate the HTML, which will run `generate.odin`. Then, check the `out` folder for the full website. Because the website uses links, you'll likely need an HTTP server. The easiest approach is `python -m http.server -d out/Home`, which will start a local server for you.

## Contributing
Feel free to contribute! Try and make sure your info is correct. If you're referencing any niche information (especially removed features and things), please provide some sources in your PR message, ideally from the Odin compiler directly.

Avoid dead links! If you have the http server running, you can use `link_verifier.py` to see if you have any links that don't go anywhere. Missing headings are, of course, not ideal, but it's not the end of the world.