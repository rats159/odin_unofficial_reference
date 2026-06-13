# Unofficial Odin Reference
This is the repository for my unofficial Odin reference.

## Building the website
The HTML is generated from Markdown files, stored at `root`. You should just be able to run `odin run .` to generate the HTML, which will run `generate.odin`. Then, check the `out` folder for the full website. Because the website uses links, you'll likely need an HTTP server. The easiest approach is `python -m http.server -d out/Home`, which will start a local server for you.

## Contributing
Feel free to contribute! Do not submit incorrect info. If you're referencing any niche information (especially removed features and things), please provide some sources in your PR message, ideally from the Odin compiler directly.