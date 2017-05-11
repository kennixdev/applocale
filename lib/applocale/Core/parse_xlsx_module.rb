module Applocale

  module ParseXLSXModule
    class SheetContent
      attr_accessor :sheetname, :header_rowno, :keyStrWithColNo, :langWithColNo_list, :rowinfo_list, :comment

      def initialize(sheetname)
        self.sheetname = sheetname
        self.rowinfo_list = Array.new()
        self.langWithColNo_list = Array.new()
        self.comment = sheetname
      end

      def getRowInfoSortByKey()
        return self.rowinfo_list.sort_by { |obj| obj.key_str.to_s }
      end

      def getRowInfoSortByRowNo()
        return self.rowinfo_list.sort_by { |obj| obj.rowno.to_i }
      end

      def to_s
        str_keyStrWithColNo = ""
        if !keyStrWithColNo.nil?
          str_keyStrWithColNo = "\n\t#{keyStrWithColNo.to_s}"
        end
        str_langWithColNo_list = ""
        self.langWithColNo_list.each do |langWithColNo|
          str_langWithColNo_list += "\n\t#{langWithColNo.to_s}"
        end
        str_contentlist = "\n"
        self.getRowInfoSortByRowNo().each do |value|
          str_contentlist += "\t #{value.to_s}\n"
        end

        "sheetname = #{sheetname}\n" +
            "header_rowno = #{header_rowno}\n" +
            "keyStrWithColNo = #{str_keyStrWithColNo}\n" +
            "langWithColNo_list = #{str_langWithColNo_list}\n" +
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