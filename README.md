# Run a gist!

This is running at http://GIST-ID.run-a-gist.herokuapp.com. It will map requests to files within the corresponding GIST.

The path / maps to index.html, everything else is dispatched as is.

For a given url, if it is present directly within the gist, it will be served as-is. Otherwise, other formats are supported:

* <name>.html will look for <name>.haml and compile it before serving.
* <name>.css will look for <name>.scss or <name>.sass and serve the compiled version.
* <name>.js will look for <name>.coffee and serve the compiled version.

For an example, go to http://2879097.run-a-gist.herokuapp.com/
