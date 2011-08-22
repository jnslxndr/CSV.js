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
  oncomment    ?= null
  
  # return null, if line is a comment line
  if this.charAt(0) is "#"
    oncomment(this.shift()) if oncomment
    return null
  
  # pattern = new RegExp "([^'\"\\\\]|,?),(?=[^\\1]|$)","gm"
  pattern = new RegExp "([^'\"\\\\]|"+delimiter+"?)"+delimiter+"(?=[^\\1]|$)","gm"
  
  console.log pattern
  line = []
  last_index = 0
  while result = pattern.exec this.toString()
    index = (result[0].search delimiter)+result.index
    line.push this.toString().substring(last_index,index).trim().replace('\\','')
    last_index = index+1
  # get the last result too
  line.push this.toString().substring(last_index,this.length).trim().replace('\\','')
  
  # trigger the callback
  onresult(line) if onresult
  
  return line


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


# 
# 
# String.prototype.csvToJson = function (options) {
String.prototype.csvToJson = (options) ->
  comment_char ?= "#"
  delimiter    ?= ","
  onlineresult ?= undefined
  oncomment    ?= undefined
  onresult     ?= undefined
  
  fill_empty   = options['fill_empty']   || true;
  onprogress   = options['onprogress']   || undefined;
  onerror      = options['onerror']      || undefined;
  oncomplete   = options['oncomplete']   || undefined;
  headers      = options['headers']      || undefined;

  csvRows = [];
  objArr = [];
  error = false;
  csvText = this;
  jsonText = "";
  
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
