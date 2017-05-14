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
    @setting = Setting

    def initialize(skip_error = false)
      @skip_error = skip_error
      @setting = Setting
      FileUtils.mkdir_p(File.dirname(@setting.xlsxpath))
      FileUtils.rm(@setting.xlsxpath) if File.exist? @setting.xlsxpath
      keystr_with_colno = ParseXLSXModule::KeyStrWithColNo.new(@setting.keystr, 0)
      lang_with_colno_list = Array.new
      colno = 1
      @setting.langlist.each do |key, langinfo|
        langwith_colno = ParseXLSXModule::LangWithColNo.new(langinfo[:xlsheader], key, colno)
        colno+=1
        lang_with_colno_list.push(langwith_colno)
      end
      if @setting.platform == Platform::IOS
        result = self.parse_ios
        write_to_xlsx(@setting.xlsxpath, keystr_with_colno, lang_with_colno_list, result[:errorlist], result[:content], result[:keylist])
      else
        result = self.parse_android
        write_to_xlsx(@setting.xlsxpath, keystr_with_colno, lang_with_colno_list, result[:errorlist], result[:content], result[:keylist])
      end
    end

    def parse_ios
      result = ParseStringsFile.new
      errorlist = result.errorlist
      content = result.strings_keys
      keylist = result.keys_list
      return {:errorlist => errorlist, :content => content, :keylist => keylist}
    end

    def parse_android
      result = ParseXMLFile.new
      errorlist = result.errorlist
      content = result.strings_keys
      keylist = result.keys_list
      return {:errorlist => errorlist, :content => content, :keylist => keylist}
    end

    def write_to_xlsx(path, keystrwithColNo, langwithColNolist, errorlist, content, keylist)
      ErrorUtil::ParseLocalizedError::ParseLocalizedError.raiseArr(errorlist, !@skip_error)
      puts "Start write to file: \"#{path}\" ...".green
      workbook = RubyXL::Workbook.new
      worksheet = workbook.worksheets[0]
      rowno = 0
      worksheet.add_cell(rowno, keystrwithColNo.colno, keystrwithColNo.header_str)
      langwithColNolist.each do |langwithColNo|
        worksheet.add_cell(rowno, langwithColNo.colno, langwithColNo.header_str)
      end
      rowno+=1
      keylist.each do |key|
        worksheet.add_cell(rowno, keystrwithColNo.colno, key)
        unless content[key].nil?
          langwithColNolist.each do |langwithColNo|
            lang = langwithColNo.lang.to_s
            worksheet.add_cell(rowno, langwithColNo.colno, content[key][lang][:value]) if !content[key][lang].nil? && !content[key][lang][:value].nil?
          end
        end
        rowno+=1
      end
      workbook.write(path)
    end

  end
end