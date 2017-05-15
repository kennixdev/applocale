require File.expand_path('../../setting.rb', __FILE__)
require File.expand_path('../parse_xlsx_module.rb', __FILE__)
require File.expand_path('../../../Util/error_util.rb', __FILE__)
require File.expand_path('../../../Util/regex_util.rb', __FILE__)

require 'rubyXL'
require 'colorize'

module Applocale
  class ParseXLSX

    @xlsx = nil
    @sheetcontent_list = nil
    @allkey_dict = {}
    @all_error = nil
    @setting = Setting

    def initialize
      @setting = Setting
      puts "Start to Parse XLSX: \"#{@setting.xlsxpath}\" ...".green
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
        workbook = RubyXL::Parser.parse(@setting.xlsxpath)
      rescue
        ErrorUtil::CannotOpenXlsxFile.new(@setting.xlsxpath).raise
      end
      workbook.worksheets.each do |worksheet|
        sheetname = worksheet.sheet_name
        sheetcontent = ParseXLSXModule::SheetContent.new(sheetname)
        rowno = -1
        worksheet.each {|row|
          rowno += 1
          # colno = 0
          next if row.nil?
          cells = row && row.cells
          if sheetcontent.header_rowno.nil?
            headerinfo = find_header(cells)
            unless headerinfo.nil?
              sheetcontent.header_rowno = rowno
              sheetcontent.keyStr_with_colno = headerinfo[:keystr_colno]
              sheetcontent.lang_with_colno_list = headerinfo[:lang_colno]
            end
          else
            begin
              rowcontent = parse_row(sheetname, rowno, worksheet.sheet_data[rowno], sheetcontent.keyStr_with_colno, sheetcontent.lang_with_colno_list)
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
        cell = cells[keystr_with_colno.colno]
        val = cell && cell.value
        keystr = to_value_key(val)
      rescue ErrorUtil::ParseXlsxError::InValidKey => e
        e.rowinfo.sheetname = sheetname
        e.rowinfo.rowno = rowno
        raise e
      end

      unless keystr.nil?
        rowinfo = ParseXLSXModule::RowInfo.new(sheetname, rowno, keystr)
        (0..lang_with_colno_list.length-1).each do |k|
          lang_with_colno = lang_with_colno_list[k]
          cell = cells[lang_with_colno.colno]
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
        if ValidKey.is_validkey(@setting.platform, new_value)
          return new_value
        else
          rowinfo = ParseXLSXModule::RowInfo.new(nil, nil, value)
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

    def find_header(cells)
      keystr_with_colno = nil
      lang_with_colno_list = Array.new
      k_header_lang_dict = []
      colno = 0
      cells.each{ |cell|
        value = cell && cell.value
        unless value.nil?
          if value == @setting.keystr && keystr_with_colno.nil?
            keystr_with_colno = ParseXLSXModule::KeyStrWithColNo.new(value, colno)
          else
            @setting.langlist.each do |lang, info|
              if value == info[:xlsheader] && k_header_lang_dict.index(lang).nil?
                lang_with_colno_list.push(ParseXLSXModule::LangWithColNo.new(info[:xlsheader], lang, colno))
                k_header_lang_dict.push(lang)
              end
            end
          end
        end
        colno += 1
      }
      if !keystr_with_colno.nil? && lang_with_colno_list.length == @setting.langlist.length
        return {:keystr_colno => keystr_with_colno, :lang_colno => lang_with_colno_list}
      end
    end

  end
end
