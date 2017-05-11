require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../parse_xlsx_module.rb', __FILE__)
require File.expand_path('../../Util/error_util.rb', __FILE__)
require File.expand_path('../../Util/color_util.rb', __FILE__)
require File.expand_path('../../Util/regex_util.rb', __FILE__)

require 'rubyXL'


module Applocale
  class ParseXLSX

    @xlsx = nil
    @sheetcontent_list = nil
    @allError = nil
    @setting = Setting

    def initialize()
      @setting = Setting
      puts "Start to Parse XLSX: \"#{@setting.xlsxpath}\" ...".green
      # @xlsx = Roo::Spreadsheet.open(@@setting.xlsxpath)
      @sheetcontent_list = Array.new
      @allKeyDict = {}
      @allError = Array.new

      self.parse()
    end

    def result
      return @sheetcontent_list
    end

    def parse()

      workbook = RubyXL::Parser.parse(@setting.xlsxpath)
      workbook.worksheets.each do |worksheet|
        sheetName = worksheet.sheet_name
        sheetcontent = ParseXLSXModule::SheetContent.new(sheetName)

        rowno = -1
        worksheet.each {|row|
          rowno += 1
          # colno = 0
          next if row.nil?
          cells = row && row.cells
          if sheetcontent.header_rowno.nil?
            headerinfo = findHeader(cells)
            if !headerinfo.nil?
              sheetcontent.header_rowno = rowno
              sheetcontent.keyStrWithColNo = headerinfo[:keystr_colno]
              sheetcontent.langWithColNo_list = headerinfo[:lang_colno]
            end
          else
            begin
              rowcontent = parseRow(sheetName, rowno, worksheet.sheet_data[rowno], sheetcontent.keyStrWithColNo, sheetcontent.langWithColNo_list)
              if !rowcontent.nil?
                prev_rowcontent = @allKeyDict[rowcontent.key_str.downcase]
                if prev_rowcontent.nil?
                  @allKeyDict[rowcontent.key_str.downcase] = rowcontent
                  sheetcontent.rowinfo_list.push(rowcontent)
                else
                  error = ErrorUtil::ParseXlsxError::ErrorDuplicateKey.new(rowcontent, "duplicate with sheet '#{prev_rowcontent.sheetname}' row '#{prev_rowcontent.rowno}'")
                  @allError.push(error)
                end
              end
            rescue ErrorUtil::ParseXlsxError::ParseError => e
              @allError.push(e)

            end
          end

          # row && row.cells.each {|cell|
          #   val = cell && cell.value
          #   puts "#{rowno} - #{colno} = #{val}"
          #
          #
          #
          #   colno += 1
          # }


        }

        if sheetcontent.header_rowno.nil?
          ErrorUtil::ParseXlsxError::HeadeNotFoundError.new("Header not found in sheet: #{sheetName}").to_warn
        end
        @sheetcontent_list.push(sheetcontent)
      end
      if @allError.length > 0
        ErrorUtil::ParseXlsxError::ParseError.raiseArr(@allError)
      end

    end

    def parseRow(sheetname, rowno, cells, keyStrWithColNo, langWithColNo_list)
      begin
        cell = cells[keyStrWithColNo.colno]
        val = cell && cell.value
        keystr = toValueKey(val)
      rescue ErrorUtil::ParseXlsxError::ErrorInValidKey => e
        e.rowinfo.sheetname = sheetname
        e.rowinfo.rowno = rowno
        raise e
      end

      if !keystr.nil?
        rowinfo = ParseXLSXModule::RowInfo.new(sheetname, rowno, keystr)
        for k in 0..langWithColNo_list.length-1
          langWithColNo = langWithColNo_list[k]
          cell = cells[langWithColNo.colno]
          val = cell && cell.value
          cell_value = val.to_s
          lang_name = langWithColNo.lang
          rowinfo.content_dict[lang_name] = convertContect(cell_value)
        end
        return rowinfo
      end
      return nil
    end

    def toValueKey(value)
      if !value.nil? && value != ""
        new_value = value.to_s
        if ValidKey.isValidKey(@setting.platform, new_value)
          return new_value
        else
          rowinfo = ParseXLSXModule::RowInfo.new(nil, nil, value)
          raise ErrorUtil::ParseXlsxError::ErrorInValidKey.new(rowinfo, "Invaild Key: #{value}")
        end
      end
      return nil
    end

    def convertContect(cell_value)
      if cell_value.nil?
        return ""
      else
        return cell_value
      end
    end

    def findHeader(cells)
      keyStrWithColNo = nil
      langWithColNo_list = Array.new()
      k_header_lang_dict = []
      colno = 0
      cells.each{ |cell|
        value = cell && cell.value
        if !value.nil?
          if value == @setting.keystr && keyStrWithColNo.nil?
            keyStrWithColNo = ParseXLSXModule::KeyStrWithColNo.new(value, colno)
          else
            @setting.langlist.each do |lang, info|
              if value == info[:xlsheader] && k_header_lang_dict.index(lang).nil?
                langWithColNo_list.push(ParseXLSXModule::LangWithColNo.new(info[:xlsheader], lang, colno))
                k_header_lang_dict.push(lang)
              end
            end
          end
        end
        colno += 1
      }

      allPass = true
      for i in 0..langWithColNo_list.length-1
        if langWithColNo_list[i].nil?
          allPass = false
          break
        end
      end
      if !keyStrWithColNo.nil? && langWithColNo_list.length == @setting.langlist.length
        return {:keystr_colno => keyStrWithColNo, :lang_colno => langWithColNo_list}
      end
      return nil
    end

  end
end
