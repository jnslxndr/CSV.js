##
# A Basic CSV Parser
#

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
    line = combineToOject(options.headers,line)
    
  # trigger the callback
  options.onresult(line) if options.onresult
  
  return line


String.prototype.parseMultiLineCSV = (options) ->
  options ?= {}
  options.comment_char ?= "#"
  options.delimiter    ?= String.CSV_DELIMITER_COMMA
  options.fill_empty   ?= true
  options.headers      ?= false
  options.lowercase_headers      ?= false
  
  options.onprogress   ?= ()->null
  options.onerror      ?= ()->null
  options.oncomplete   ?= ()->null
  options.oncomment    ?= ()->null
  options.onresult     ?= ()->null
  options.json         ?= false
  
  if this.toString() is ""
    options.onerror
    return null
  
  pattern = /(.*)\s*[\r\n]+\s*/g
  lines   = []
  
  # walk over water:
  while line = pattern.exec this.toString()
    _line = line[1].parseCSVLine(options)
    
    ###
      TODO Handle the fill option properly
    ###
    
    if _line and options.json and options.headers is true
      options.headers = _line.map (l)=> return l.saneParam()
      continue
    else 
      lines.push _line unless !_line
      options.onprogress _line unless !_line
  
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
combineToOject = (keys,values) ->
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

