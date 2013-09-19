#!/usr/bin/env node
var x = require('../lib/index')
var argv = require('optimist').argv

x.transform_file( argv._[0], argv.out )