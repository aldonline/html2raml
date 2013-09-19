html_2_jquery    = require './html_2_jquery'
_                = require 'underscore'
fs               = require 'fs'
path             = require 'path'

$ = null # TODO: fix this!

indent = (num) -> ('  ' for i in [0..num] ).join ''

is_blank_text_node = ( x ) -> x instanceof TextNode and x.value().trim() is ''

module.exports =
  transform: transform = ( html_str, cb ) ->
    html_2_jquery html_str, ( err, $x, window ) ->
      $ = $x
      $root = $ window.document
      if $root.find('body').length isnt 0
        $root = $root.find 'body'
      cb null, ( new DOMNode( $root[0] ) ).print().join '\n'

  transform_file: ( from, to, cb ) ->
    from = path.resolve process.cwd(), from
    to   = path.resolve process.cwd(), to
    transform fs.readFileSync(from).toString(), (e, r) ->
      fs.writeFileSync to, r
      cb?()

get_attribute_names = ( el ) ->
  attrs = el.attributes
  attrs.item(i).nodeName for i in [0...attrs.length]

get_attribute_map = ( el ) ->
  names = get_attribute_names el
  $el = $(el)
  obj = {}
  for name in names
    obj[name] = $el.attr name
  obj

class TextNode
  constructor: ( @n ) ->
  tag: -> '_text'
  value: -> @n.nodeValue
  print: (depth = 0) -> [ indent(depth) + "'_text'._ " + JSON.stringify(@n.nodeValue) ]

class DOMNode
  constructor: ( @e ) ->

  tag: -> @_tag ?= do =>
    arr = [ @e.nodeName.toLowerCase() ]
    if ( id = @attr_map().id )? then arr.push '#' + id
    arr = arr.concat ( '.' + c for c in @classes() )
    arr.shift() if arr.length > 1 and arr[0] is 'div'
    arr.join ''
  
  classes: -> @_classes ?= do => require('./parse_class_attribute') @attr_map()['class'] or ''

  attr_map: -> @_attr_map ?= do => get_attribute_map @e

  styles: -> # TODO: parse style attribute

  events: ->

  children: -> @_children ?= do =>
    for c in @e.childNodes when c.nodeName.toLowerCase() not in ['script', 'style']
      if c.nodeName is '#text' then new TextNode c else new DOMNode c

  print: (depth = 0, parent_tag) ->
    raw_tag = @tag()
    raw_tag = parent_tag + ' ' + raw_tag if parent_tag?
    tag = "'" + raw_tag + "'._"

    raml_props = {}
    for own k, v of @attr_map() when k not in [ 'class', 'style', 'id' ]
      raml_props[k] = JSON.stringify v
    props = ( k + ':' + v for k, v of raml_props ).join ', '
    last_comma = if props.length is 0 then ' ' else ', '

    line = indent(depth) + tag + ' ' + props

    cs = @children()

    if cs.length is 0
      [ line ]
    else if cs.length is 1 and cs[0] instanceof TextNode
      # special case. use raw text
      [ line + last_comma + JSON.stringify cs[0].value() ]
    else
      # remove first and last text nodes
      cs.shift() while is_blank_text_node cs[0]
      cs.pop() while is_blank_text_node cs[cs.length - 1]
      if cs.length is 1 and props.length is 0
        cs[0].print(depth, raw_tag)
      else
        child_lines = ( c.print(depth + 1) for c in cs )
        _.flatten [ line + last_comma + '->' ].concat child_lines