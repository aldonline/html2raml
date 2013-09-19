min = require 'html-minifier'

# TODO: use http://w3c.github.io/tidy-html5/quickref.html
# http://perfectionkills.com/experimenting-with-html-minifier/#options

collapse_ws_re = /[\s]{1,}/g
collapse_ws = ( str ) -> str.replace collapse_ws_re, ' '

module.exports = ( html_str ) ->
  x = min.minify html_str,
    removeComments: yes
    removeCDATASectionsFromCDATA: true
    removeEmptyAttributes: yes
  x = collapse_ws x  
  x = min.minify x, collapseWhitespace: yes
  x