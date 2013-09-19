jsdom  = require 'jsdom'
jQuery = require 'jQuery'
tidy   = require './tidy_html'

module.exports = ( html_str, cb ) ->
  jsdom.env tidy(html_str), [], ( errors, window ) ->
    return cb? errors if errors?
    cb? null, jQuery.create( window ), window