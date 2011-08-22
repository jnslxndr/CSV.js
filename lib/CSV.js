(function() {
  String.prototype.parseCSVLine = function(delimiter, comment_char, onresult) {
    var index, last_index, line, pattern, result;
    if (comment_char == null) {
      comment_char = "#";
    }
    if (delimiter == null) {
      delimiter = ",";
    }
    if (onresult == null) {
      onresult = null;
    }
    if (this.charAt(0) === "#") {
      return null;
    }
    if (delimiter == null) {
      delimiter = ",";
    }
    /*
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
      */
    pattern = new RegExp("(?:[^'\"\\\\]),(?=[^\\1]|$)", "gm");
    line = [];
    last_index = 0;
    while (result = pattern.exec(this.toString())) {
      index = (result[0].search(',')) + result.index;
      line.push(this.toString().substring(last_index, index).trim().replace('\\', ''));
      last_index = index + 1;
    }
    line.push(this.toString().substring(last_index, this.length).trim().replace('\\', ''));
    if (onresult) {
      onresult(line);
    }
    return line;
  };
}).call(this);
