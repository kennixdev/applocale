

module Applocale


  module ParseXLSXModule
    class Helper
      def self.collabel_to_colno(collabel)
        if collabel.match(/^(\d)+$/)
          return collabel.to_i
        end
        number = collabel.tr("A-Z", "1-9a-q").to_i(27)
        number -= 1 if number > 27
        return number
      end
    end


    class SheetContent
      attr_accessor :sheetname, :header_rowno, :keyStr_with_colno, :lang_with_colno_list, :rowinfo_list, :comment

      def initialize(sheetname)
        self.sheetname = sheetname
        self.rowinfo_list = Array.new
        self.lang_with_colno_list = Array.new
        self.comment = sheetname
      end

      def get_rowInfo_sortby_key
        return self.rowinfo_list.sort_by { |obj| obj.key_str.to_s }
      end

      def get_rowInfo_sortby_rowno
        return self.rowinfo_list.sort_by { |obj| obj.rowno.to_i }
      end

      def to_s
        str_keyStr_with_colno = ''
        unless keyStr_with_colno.nil?
          str_keyStr_with_colno = "\n\t#{keyStr_with_colno.to_s}"
        end
        str_lang_with_colno_list = ''
        self.lang_with_colno_list.each do |langWithColNo|
          str_lang_with_colno_list += "\n\t#{langWithColNo.to_s}"
        end
        str_contentlist = '\n'
        self.get_rowInfo_sortby_rowno.each do |value|
          str_contentlist += "\t #{value.to_s}\n"
        end
        "sheetname = #{sheetname}\n" +
            "header_rowno = #{header_rowno}\n" +
            "keyStrWithColNo = #{str_keyStr_with_colno}\n" +
            "langWithColNo_list = #{str_lang_with_colno_list}\n" +
            "rowinfo_list = #{str_contentlist}"
      end
    end

    class RowInfo

      attr_accessor :sheetname, :rowno, :key_str, :content_dict

      def initialize(sheetname = nil, rowno = nil, key_str = nil)
        self.sheetname = sheetname
        self.rowno = rowno
        self.key_str = key_str
        self.content_dict = {}
      end

      def to_s
        "sheetname = #{sheetname}, rowno = #{rowno}, key_str = #{key_str}, content_dict = #{content_dict}"
      end

    end

    class KeyStrWithColNo

      attr_accessor :header_str, :colno

      def initialize(header_str, colno)
        self.header_str = header_str
        self.colno = colno
      end

      def to_s
        "{header_str => #{header_str}, colno => #{colno}}"
      end

    end

    class LangWithColNo
      attr_accessor :header_str, :lang, :colno

      def initialize(header_str, lang, colno)
        self.header_str = header_str
        self.lang = lang
        self.colno = colno
      end

      def to_s
        "{header_str => #{header_str}, lang => #{lang}, colno => #{colno}}"
      end

    end

  end
end


module Applocale
  module Config
    class SheetInfoByRow
      def to_keyStrWithColNo(sheetcontent)
        sheetcontent.header_rowno = self.row
        keycolno = Applocale::ParseXLSXModule::Helper.collabel_to_colno(self.key_col)
        sheetcontent.keyStr_with_colno = ParseXLSXModule::KeyStrWithColNo.new(nil, keycolno)
        sheetcontent.lang_with_colno_list = Array.new
        self.lang_cols.each do |lang, collabel|
          colno = Applocale::ParseXLSXModule::Helper.collabel_to_colno(collabel)
          obj = ParseXLSXModule::LangWithColNo.new(nil,lang, colno)
          sheetcontent.lang_with_colno_list.push(obj)
        end
      end
    end
  end
end

