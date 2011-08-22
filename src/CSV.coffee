##
# A Basic CSV Parser
#

# // some regex patterns:
# // ^(("(?:[^"]|"")*"|[^,]*)(,("(?:[^"]|"")*"|[^,]*))*)$
# split a line (does not work in javascript because of no support for lookbehinds)
# (?<=[^'"\\]),(?=[^\1]|$)

String.prototype.parseCSVLine = (delimiter,comment_char,onresult) ->
  comment_char ?= "#"
  delimiter    ?= ","
  onresult     ?= null
  
  # return null, if line is a comment line
  return null if this.charAt(0) is "#"
  
  delimiter ?= ","
  # line       = this.split delimiter
  
  
  ###
  # check for splits performed inside quoted strings and correct if needed
  for i in [0..line.length]
    chunk = line[i].replace /^[\s]*|[\s]*$/g, "" # trim the line
    quote = "";
    
    quote = chunk.charAt(0) if chunk.charAt(0) is '"' or chunk.charAt(0) is "'"
    quote = "" if quote isnt "" and chunk.charAt(chunk.length - 1) is quote
    
    if quote != ""
      j = i + 1
      chunk = line[j].replace /^[\s]*|[\s]*$/g, "" if j < line.length
      
      while j < line.length and chunk.charAt(chunk.length - 1) isnt quote
        line[i] += ',' + line[j]
        line.splice(j, 1)
        chunk = line[j].replace(/[\s]*$/g, "")
      
      if j < line.length
        line[i] += ',' + line[j]
        line.splice j, 1
    
    i++
  
  for i in [0..line.length]
    # remove leading/trailing whitespace
    line[i] = line[i].replace /^[\s]*|[\s]*$/g, ""
    # remove leading/trailing quotes
    if line[i].charAt(0) is '"'
      line[i] = line[i].replace /^"|"$/g, ""
    else if line[i].charAt(0) is "'"
      line[i] = line[i].replace /^'|'$/g, ""
  ###
  
  pattern = new RegExp "(?:[^'\"\\\\]),(?=[^\\1]|$)","gm"
  line = []
  last_index = 0
  while result = pattern.exec this.toString()
    index = (result[0].search ',')+result.index
    line.push this.toString().substring(last_index,index).trim().replace('\\','')
    last_index = index+1
  line.push this.toString().substring(last_index,this.length).trim().replace('\\','')
  
  # trigger the callback
  onresult(line) if onresult
  
  return line
  
# 
# String.prototype.saneParam = function(tolower) {
#   var sane = this.replace(/^\s+/, '').
#         replace (/ä+/, 'ae').
#         replace (/ö+/, 'oe').
#         replace (/ü+/, 'ue').
#         replace (/Ä+/, 'Ae').
#         replace (/Ö+/, 'Oe').
#         replace (/Ü+/, 'Ue').
#         replace (/ß+/, 'ss').
#         replace (/\s+$/, '_').
#         replace(/[^A-z0-9]+/gi,'');
#     return tolower ? sane.toLowerCase():sane;
# }
# 
# 
# String.prototype.csvToJson = function (options) {
#   var delimiter    = options['delimiter']    || ",";
#   var comment_char = options['comment_char'] || "#";
#   var fill_empty   = options['fill_empty']   || true;
#   var onprogress   = options['onprogress']   || undefined;
#   var onerror      = options['onerror']      || undefined;
#   var oncomplete   = options['oncomplete']   || undefined;
#   var headers      = options['headers']      || undefined;
#   
#   var csvRows = [];
#   var objArr = [];
#   var error = false;
#   var csvText = this;
#   var jsonText = "";
# 
#   if (csvText == "") {
#     error = true;
#     jsonText=this;
#   }
# 
#   if (!error) {
#     csvRows = csvText.split(/[\r\n]/g); // split into rows
#     
#     // get rid of empty rows
#     for (var i = 0; i < csvRows.length; i++) {
#       if (csvRows[i].replace(/^[\s]*|[\s]*$/g, '') == "") {
#         csvRows.splice(i, 1);
#         i--;
#       }
#     }
# 
#     if (csvRows.length > 2) {
#       objArr = [];
#       var fields = null;
#       var ob_index = 0;
#       var over_all_index = 0;
#       csvRows.map(function(row,index,source){
#         row = row.parseCSVLine(delimiter);
# 
#         var result = true;
#         
#         if (row.trim().length <= 0)
#         {
#           result = false; // check for sane row
#         }
#         
#         if (result && fields==null)
#         {
#           fields = row.empty()?null:row; // set the fields from the first valid row
#           result = false;
#         } 
#         
#         if (result && fields.empty()){
#           result = false;
#           throw new Error(fields);
#         } 
#         
#         var frag = {};
#         if(result)
#         {
#           // We are save to parse:
#           for (var j = 0; j < fields.length; j++) {
#             // objArr[ob_index][fields[j].saneParam()] = row[j];
#             frag[fields[j].saneParam(true)] = row[j];
#           }
#           objArr.push(frag);
#           result = JSON.stringify(frag)!=='{}';
#           ob_index++;
#         }
#         
#         if(undefined!=onprogress && typeof onprogress == "function")
#         {
#           onprogress(over_all_index/(source.length-1),frag,result)
#         }
#         
#         if(result===false && undefined!=onerror && typeof onerror == "function")
#         {
#           onprogress({current_row:row})
#         }
#         
#         over_all_index++;
#       });
#       
#       if(undefined!=oncomplete && typeof oncomplete == "function")
#       {
#         oncomplete()
#       }
#       
#       jsonText = (undefined==fill_empty)?objArr.FILL():objArr; // FIXED logic error
#     }
#   }
#   return jsonText;
# }
# 
# 
# /**
#  * Trim an array, a.k.a. discard empty values
#  */
# Array.prototype.trim = function(){
#   return this.filter(function(el){
#     if(el instanceof Array || el instanceof String){
#       return el.trim().length > 0;
#     }
#     else if (undefined === el || el === null)
#     {
#       return false;
#     }
#     else
#     {
#       return true;
#     }
#   })
# }
# 
# /**
#  * Return a unique array
#  */
# Array.prototype.unique = function(){
#   var new_array = [];
#   while (i < this.length) {
#     if(!new_array.contains(this[i])) new_array.push(this[i]);
#   }
#   return new_array;
# }
# 
# 
# /**
#  * Check, if array only contains empty values
#  */
# Array.prototype.empty = function(){
#   return this.length!=this.trim().length;
# }
# 
# /**
#  * Fill up empty values of objects with values of
#  * the preceeding object in a collection of concurrend
#  * models.
#  */
# Array.prototype.FILL = function() {
#   var prev_object = null;
#   this.map( function(current_object) {
#     for (var key in current_object) {
#       if (current_object[key]=="" &&
#         prev_object.hasOwnProperty(key) &&
#         prev_object[key]!="") {
#         current_object[key] = prev_object[key];
#       }
#     }
#     prev_object = current_object;
#     return current_object;
#   })
#   delete prev_object;
#   return this;
# }
# 