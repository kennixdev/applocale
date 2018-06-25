require File.expand_path('../../setting.rb', __FILE__)
require File.expand_path('../parse_xlsx_module.rb', __FILE__)
require File.expand_path('../../../Util/error_util.rb', __FILE__)
require File.expand_path('../../../Util/regex_util.rb', __FILE__)
require File.expand_path('../../ParseModel/parse_model_module.rb', __FILE__)

require 'rubyXL'
require 'colorize'
module Applocale
  class Injeust

  end
end

module Applocale
  class ParseXLSX

    @sheetcontent_list = nil
    @allkey_dict = {}
    @all_error = nil

    @platform
    @xlsxpath
    @langlist
    @sheetobj_list

    def initialize(platfrom, xlsxpath, langlist, sheetobj_list)
      @platform = platfrom
      @xlsxpath = xlsxpath
      @langlist = langlist
      @sheetobj_list = sheetobj_list
      puts "Start to Parse XLSX: \"#{@xlsxpath}\" ...".green
      @sheetcontent_list = Array.new
      @allkey_dict = {}
      @all_error = Array.new
      self.parse
    end

    def result
      return @sheetcontent_list
    end

    def parse
      begin
        workbook = RubyXL::Parser.parse(@xlsxpath)
      rescue
        ErrorUtil::CannotOpenXlsxFile.new(@xlsxpath).raise
      end
      sheetnamelist = Applocale::Config::Sheet.get_sheetlist(@sheetobj_list)
      worksheets = workbook.worksheets
      sorted_worksheets = sheetnamelist
        .map { |sheet_name| worksheets.find { |worksheet| worksheet.sheet_name == sheet_name } }
        .compact

      sorted_worksheets.each do |worksheet|
        sheetname = worksheet.sheet_name
        sheetinfoobj = Applocale::Config::Sheet.get_sheetobj_by_sheetname(@sheetobj_list, sheetname)
        if sheetinfoobj.nil?
          next
        end
        sheetnamelist.delete(sheetname)

        sheetcontent = ParseModelModule::SheetContent.new(sheetname)
        if sheetinfoobj.is_a? Applocale::Config::SheetInfoByRow
          keycolno = Applocale::ParseXLSXModule::Helper.collabel_to_colno(sheetinfoobj.key_col)
          sheetinfoobj.to_keyStrWithColNo(sheetcontent)
        end

        rowno = 0
        worksheet.each {|row|
          rowno += 1
          # colno = 0
          if sheetcontent.header_rowno.nil?
            if sheetinfoobj.is_a? Applocale::Config::SheetInfoByHeader
              next if row.nil?
              cells = row && row.cells
              headerinfo = find_header(sheetinfoobj, cells)
              unless headerinfo.nil?
                sheetcontent.header_rowno = rowno
                sheetcontent.keyStr_with_colno = headerinfo[:keystr_colno]
                sheetcontent.lang_with_colno_list = headerinfo[:lang_colno]
              end
            end
          elsif sheetcontent.header_rowno > rowno
            next
          else
            next if row.nil?
            cells = row && row.cells
            begin
              rowcontent = parse_row(sheetname, rowno, cells, sheetcontent.keyStr_with_colno, sheetcontent.lang_with_colno_list)
              unless rowcontent.nil?
                prev_rowcontent = @allkey_dict[rowcontent.key_str.downcase]
                if prev_rowcontent.nil?
                  @allkey_dict[rowcontent.key_str.downcase] = rowcontent
                  sheetcontent.rowinfo_list.push(rowcontent)
                else
                  error = ErrorUtil::ParseXlsxError::DuplicateKey.new(rowcontent, prev_rowcontent.sheetname, prev_rowcontent.rowno)
                  @all_error.push(error)
                end
              end
            rescue ErrorUtil::ParseXlsxError::ParseError => e
              @all_error.push(e)

            end
          end
        }
        if sheetcontent.header_rowno.nil?
          ErrorUtil::ParseXlsxError::HeadeNotFound.new(sheetname).to_warn
        end
        @sheetcontent_list.push(sheetcontent)
      end
      if @all_error.length > 0
        ErrorUtil::ParseXlsxError::ParseError.raiseArr(@all_error)
      end

    end

    def parse_row(sheetname, rowno, cells, keystr_with_colno, lang_with_colno_list)
      begin
        cell = cells[keystr_with_colno.colno - 1 ]
        val = cell && cell.value
        keystr = to_value_key(val)
      rescue ErrorUtil::ParseXlsxError::InValidKey => e
        e.rowinfo.sheetname = sheetname
        e.rowinfo.rowno = rowno
        raise e
      end

      unless keystr.nil?
        rowinfo = ParseModelModule::RowInfo.new(sheetname, rowno, keystr)
        lang_with_colno_list.each do |lang_with_colno|
          cell = cells[lang_with_colno.colno - 1]
          val = cell && cell.value
          cell_value = val.to_s
          lang_name = lang_with_colno.lang
          rowinfo.content_dict[lang_name] = convert_contect(cell_value)
        end
        return rowinfo
      end
    end

    def to_value_key(value)
      if !value.nil? && value != ''
        new_value = value.to_s
        if ValidKey.is_validkey(@platform, new_value)
          return new_value
        else
          rowinfo = ParseModelModule::RowInfo.new(nil, nil, value)
          raise ErrorUtil::ParseXlsxError::InValidKey.new(rowinfo)
        end
      end
    end

    def convert_contect(cell_value)
      if cell_value.nil?
        return ''
      else
        return ContentUtil.from_excel(cell_value)
      end
    end

    def find_header(sheetinfoobj, cells)
      keystr_with_colno = nil
      lang_with_colno_list = Array.new
      k_header_lang_dict = []
      colno = 1
      cells.each{ |cell|
        value = cell && cell.value
        unless value.nil?
          if value == sheetinfoobj.key_header && keystr_with_colno.nil?
            keystr_with_colno = ParseModelModule::KeyStrWithColNo.new(value, colno)
          else
            sheetinfoobj.lang_headers.each do |lang, keyforlang|
              if value == keyforlang && k_header_lang_dict.index(lang).nil?
                lang_with_colno_list.push(ParseModelModule::LangWithColNo.new(keyforlang, lang, colno))
                k_header_lang_dict.push(lang)
              end
            end
          end
        end
        colno += 1
      }
      if !keystr_with_colno.nil? && lang_with_colno_list.length == sheetinfoobj.lang_headers.length
        return {:keystr_colno => keystr_with_colno, :lang_colno => lang_with_colno_list}
      end
    end

  end
end
