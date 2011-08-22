describe "Parsing CSV", ->
  
  # ====================
  # = Test the helpers =
  # ====================
  describe "Sanitizing a headerfield", ->
    header = "äöüß*# good{as  };:S;MD;MNSjkdfhkj}"
    sane_header = "aeoeuess_good_as_S_MD_MNSjkdfhkj"
    
    it "Sane header with no case changes", ->
      (expect header.saneParam()).toEqual(sane_header)
  
    it "Sane header with to lowercase", ->
      (expect header.saneParam(true)).toEqual(sane_header.toLowerCase())
  
  # ===========
  # = Parsing =
  # ===========
  describe "Parsing a single line", ->
    
    line   =   "kjhasdkjhasd,asdasd,asdkjhkasdkh,asd\n,,"
    result =  ["kjhasdkjhasd","asdasd","asdkjhkasdkh","asd","",""]
    comment_line ="# a simple commented, but readable line, that is not parsed"
  
    it "return null on a commented line", ->
      (expect comment_line.parseCSVLine()).toBeNull()
  
    it "parse a line", ->
      expect(line.parseCSVLine()).toEqual(result);
    
    
  describe "Parsing multiple lines", ->
    multiline   = '''
    # a simple commented, but readable line, that is not parsed
    eins	zwei	drei	vier	fünf	sechs	sieben	acht	neun	zehn	und elf	und/zwölf
    eine eins	eine zwei	eine drei	eine vier	eine fünf	eine sechs	sieben	eine acht	eine neun	eine zehn	eine und elf	eine und/zwölf
    '''
    
    multiline_result = [ [ 'eins', 'zwei', 'drei', 'vier', 'fünf', 'sechs', 'sieben', 'acht', 'neun', 'zehn', 'und elf', 'und/zwölf' ], [ 'eine eins', 'eine zwei', 'eine drei', 'eine vier', 'eine fünf', 'eine sechs', 'sieben', 'eine acht', 'eine neun', 'eine zehn', 'eine und elf', 'eine und/zwölf' ] ]
    
    keys = multiline_result[0].map (k) => return k.saneParam(true)
    multiline_result_objects = [combineToObject(keys,multiline_result[1])]
    multiline_result_json = JSON.stringify(multiline_result_objects)
    

    it "parse multiple lines", ->
      (expect multiline.parseMultiLineCSV(delimiter:String.CSV_DELIMITER_TAB)).toEqual(multiline_result)
    
    it "parse multiple lines to key value object", ->
      (expect multiline.csvToObjects(delimiter:String.CSV_DELIMITER_TAB)).toEqual(multiline_result_objects)
    
    it "parse multiple lines to json string", ->
      (expect multiline.csvToJson(delimiter:String.CSV_DELIMITER_TAB)).toEqual(multiline_result_json)
    
  