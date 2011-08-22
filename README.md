This parser takes the prototype approach to make String parsable, if the are
CSV formatted. I have not been satisfied with the different parsers i could
find. So here is my bit to it.

**!! There may still be changes in the API !!**

**If you want to use it straight away, download the minified version [here](https://raw.github.com/jens-a-e/CSV.js/master/release/CSV.min.js)**


Use it the following way:

```
  var csv_string  = <where_ever_u_get_this_from>;
  
  // Get an array from a single line of csv
  var cvs_line = csv_string.parseCSVLine();
  
  // Get all lines as a matrix:
  var cvs_matrix = csv_string.parseMultiLineCSV();
  
  
  // !!The following two methods use the first line as keys for the objects!!
  // Get all lines as an array of objects:
  var cvs_matrix = csv_string.csvToObjects();
  
  // Get all lines as a jsonstring:
  var cvs_json = csv_string.csvToJson();
  
  
  // You can also pass in some options as an argument.
  // These are the defaults:
  options = {
    // Use the pound sign to signal a comment line
    comment_char: "#",
    // callback for each successfuly decoded line
    onprogress: function(current_line){},
    // callback if any error occurs
    onerror:    function(){},
    // called on complete parse
    oncomplete: function(){},
    // called if a commentline is hit
    oncomment:  function(comment_string){},
    // called when a cell is pealed out
    onresult :  function(cell_value){} // callback for 
  }
  
  // For the delimiter, try any single string, but you should
  // stick to the defaults:
  // String.CSV_DELIMITER_TAB       = '\\t'
  // String.CSV_DELIMITER_COMMA     = ',' // this is the default
  // String.CSV_DELIMITER_SEMICOLON = ';'
  
  // e.g.:
  var cvs_json = csv_string.csvToJson({
    delimiter:String.CSV_DELIMITER_TAB, // for tab seperated
  }); 
  
```

Early release, so keep watching and report any issues, make feature requests,
fork, etc :)
Written in coffee script to keep things nice an tidy.