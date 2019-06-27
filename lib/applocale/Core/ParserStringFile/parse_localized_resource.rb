require File.expand_path('../../setting.rb', __FILE__)
require File.expand_path('../../../Util/platform.rb', __FILE__)
require File.expand_path('../../ParseXLSX/parse_xlsx_module', __FILE__)
require File.expand_path('../parse_strings_file', __FILE__)
require File.expand_path('../parse_xml_file', __FILE__)

require 'rubyXL'
require 'colorize'

module Applocale
  class ParseLocalizedResource
    @skip_error = false
    @platform
    @xlsxpath
    @langpathobj_list
    @sheetobj_list
    @convert_file

    def initialize(skip_error = false, platform, xlsxpath, langpathobj_list, sheetobj_list, convert_file)
      @skip_error = skip_error
      @platform = platform
      @xlsxpath = xlsxpath
      @langpathobj_list = langpathobj_list
      @sheetobj_list = sheetobj_list
      @convert_file = convert_file
      startParse()
    end

    def startParse
      puts "Start to Parse StringFile .... ".green

      FileUtils.mkdir_p(File.dirname(@xlsxpath))
      FileUtils.rm(@xlsxpath) if File.exist? @xlsxpath

      sheetobj = @sheetobj_list[0]

      if @platform == Platform::IOS
        result = self.parse_ios
        write_to_xlsx(@xlsxpath, sheetobj, result[:errorlist], result[:content], result[:keylist])
      elsif @platform == Platform::ANDROID
        result = self.parse_android
        write_to_xlsx(@xlsxpath, sheetobj, result[:errorlist], result[:content], result[:keylist])
      else
        ErrorUtil::CommandError.new('Platform not supported').raise
      end
    end

    def parse_ios
      result = ParseStringsFile.new(@platform, @langpathobj_list, @convert_file)
      errorlist = result.errorlist
      content = result.strings_keys
      keylist = result.keys_list
      return {:errorlist => errorlist, :content => content, :keylist => keylist}
    end

    def parse_android
      result = ParseXMLFile.new(@platform, @langpathobj_list,@convert_file)
      errorlist = result.errorlist
      content = result.strings_keys
      keylist = result.keys_list
      return {:errorlist => errorlist, :content => content, :keylist => keylist}
    end

    def write_to_xlsx(path, sheetobj, errorlist, content, keylist)
      ErrorUtil::ParseLocalizedError::ParseLocalizedError.raiseArr(errorlist, !@skip_error)
      puts "Start write to file: \"#{path}\" ...".green
      workbook = RubyXL::Workbook.new
      worksheet = workbook.worksheets[0]
      worksheet.sheet_name = sheetobj.sheetname
      rowno = 0

      keycolno = 0
      langcolno_dict = {}

      sheet_info_obj = sheetobj.obj
      if sheet_info_obj.is_a? Applocale::Config::SheetInfoByHeader
        worksheet.add_cell(rowno, keycolno, sheet_info_obj.key_header)
        langcolno = keycolno + 1
        sheet_info_obj.lang_headers.each do  |key, header|
          worksheet.add_cell(rowno, langcolno, header)
          langcolno_dict[key] = langcolno
          langcolno += 1
        end
        rowno+=1
      elsif sheet_info_obj.is_a? Applocale::Config::SheetInfoByRow
        rowno = sheet_info_obj.row - 1
        keycolno = Applocale::ParseXLSXModule::Helper.collabel_to_colno(sheet_info_obj.key_col) - 1
        sheet_info_obj.lang_cols.each do |lang, collabel|
          langcolno_dict[lang] = Applocale::ParseXLSXModule::Helper.collabel_to_colno(collabel) - 1
        end
      end

      keylist.each do |key|
        worksheet.add_cell(rowno, keycolno, key)
        unless content[key].nil?
          langcolno_dict.each do |lang, colno|
            worksheet.add_cell(rowno, colno, content[key][lang][:value]) if !content[key][lang].nil? && !content[key][lang][:value].nil?
          end
        end
        rowno+=1
      end
      workbook.write(path)
    end

  end
end