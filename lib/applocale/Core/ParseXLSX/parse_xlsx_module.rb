

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
  end
end


module Applocale
  module Config
    class SheetInfoByRow
      def to_keyStrWithColNo(sheetcontent)
        sheetcontent.header_rowno = self.row
        keycolno = Applocale::ParseXLSXModule::Helper.collabel_to_colno(self.key_col)
        sheetcontent.keyStr_with_colno = Applocale::ParseModelModule::KeyStrWithColNo.new(nil, keycolno)
        sheetcontent.lang_with_colno_list = Array.new
        self.lang_cols.each do |lang, collabel|
          colno = Applocale::ParseXLSXModule::Helper.collabel_to_colno(collabel)
          obj = Applocale::ParseModelModule::LangWithColNo.new(nil,lang, colno)
          sheetcontent.lang_with_colno_list.push(obj)
        end
      end
    end
  end
end