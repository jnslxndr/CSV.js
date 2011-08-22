###
CSV.js - A Basic CSV Parser for javascript
------------------------------------------

v0.1 -- https://github.com/jens-a-e/CSV.js

This parser takes the prototype approach to make String parsable, if the are
CSV formatted. I have not been satisfied with the different parsers i could
find. So here is my bit to it.

Early release, so keep watching and report any issues :)
Written in coffee script to keep things nice an tidy.

*****
Licensed under BSD License:

Copyright (c) 2011, jens alexander ewald, jens@ififelse.net
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer. Redistributions in binary
form must reproduce the above copyright notice, this list of conditions and
the following disclaimer in the documentation and/or other materials provided
with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

###

# // some regex patterns:
# // ^(("(?:[^"]|"")*"|[^,]*)(,("(?:[^"]|"")*"|[^,]*))*)$
# split a line (does not work in javascript because of no support for lookbehinds)
# (?<=[^'"\\]),(?=[^\1]|$)

# =============
# = Constants =
# =============
String.CSV_DELIMITER_TAB       = '\\t'
String.CSV_DELIMITER_COMMA     = ','
String.CSV_DELIMITER_SEMICOLON = ';'


String.prototype.parseCSVLine = (options) ->
  options ?= {}
  options.comment_char ?= "#"
  options.delimiter    ?= String.CSV_DELIMITER_COMMA
  options.oncomment    ?= ()->null
  options.onresult     ?= ()->null
  
  # return null, if line is a comment line
  if this.charAt(0) is options.comment_char
    options.oncomment(this.toString().replace(/^#+\s+/,''))
    return null
  
  pattern = new RegExp "([^'\"\\\\]|"+options.delimiter+"?)"+options.delimiter+"(?=[^\\1]|$)","gm"
  
  line = []
  last_index = 0
  while result = pattern.exec this.toString()
    index = (result[0].search options.delimiter)+result.index
    line.push this.toString().substring(last_index,index).trim().replace('\\','')
    last_index = index+1
  # get the last result too
  line.push this.toString().substring(last_index,this.length).trim().replace('\\','')
  
  unless options.headers is true or options.headers is false or options.headers is undefined
    line = combineToObject(options.headers,line)
    
  # trigger the callback
  options.onresult(line) if options.onresult
  
  return line


String.prototype.parseMultiLineCSV = (options) ->
  options ?= {}
  options.comment_char ?= "#"
  options.delimiter    ?= String.CSV_DELIMITER_COMMA
  options.fill_empty   ?= true
  options.headers      ?= false
  options.lowercase_headers ?= false
  
  options.onprogress   ?= ()->null
  options.onerror      ?= ()->null
  options.oncomplete   ?= ()->null
  options.oncomment    ?= ()->null
  options.onresult     ?= ()->null
  options.json         ?= false
  
  if this.toString() is ""
    options.onerror
    return null
  
  pattern = /(.*)\s*[\r\n]\s*/g
  pattern = /[\r\n]?\s*(.+)\s*[\r\n]?/g
  lines   = []
  
  for line in @.match(pattern)
    _line = line.parseCSVLine(options)
    ###
      TODO Handle the fill option properly
    ###
    if _line
      if options.headers is true
        options.headers = _line.map (l)=> return l.saneParam()
        continue
      else 
        lines.push _line
        options.onprogress _line
  
  # trigger the complete handler  
  options.oncomplete lines
  
  # return the result
  lines


String.prototype.csvToObjects = (options) ->
  options ?= {}
  options.headers = true
  options.lowercase_headers = true
  return this.parseMultiLineCSV(options)

String.prototype.csvToJson = (options) ->
  options.json    = true
  return JSON.stringify(this.csvToObjects(options))


# ====================
# = Helper Functions =
# ====================
window.combineToObject = (keys,values) ->
  keys = keys.filter (k) => return k? and k isnt ""
  o = {}
  o[key] = values[i] for key,i in keys
  return o

String.prototype.saneParam = (tolower) ->
  sane = this.replace(/^\s+/, '').
  replace(/ä+/,   'ae').
  replace(/ö+/,   'oe').
  replace(/ü+/,   'ue').
  replace(/Ä+/,   'Ae').
  replace(/Ö+/,   'Oe').
  replace(/Ü+/,   'Ue').
  replace(/ß+/,   'ss').
  replace(/\s+/, '_').
  replace(/[^A-z0-9]+/gi,'_').
  replace(/_+/, '_').
  replace(/_$/, '')
  sane = sane.toLowerCase() if tolower
  return sane

