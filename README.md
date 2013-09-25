```shell
npm install html2raml -g
html2raml ./home.html -o ./home.raml.coffee
```

# Caveats

This code is so buggy that it will most likely destroy your computer.

# Strategy

* Run HTML through Tidy
* Load into JSDOM
* Query using jQuery and print output
* TODO: Compile output using coffee-script to see if it is valid
