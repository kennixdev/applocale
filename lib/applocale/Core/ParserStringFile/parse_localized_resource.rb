require File.expand_path('../../setting.rb', __FILE__)
require File.expand_path('../../../Util/platform.rb', __FILE__)
require File.expand_path('../../parse_xlsx_module', __FILE__)
require File.expand_path('../../../Util/color_util.rb', __FILE__)
require File.expand_path('../parse_strings_file', __FILE__)
require File.expand_path('../parse_xml_file', __FILE__)

require 'rubyXL'

module Applocale
  class ParseLocalizedResource

    # @xlsx = nil

    @skip_error = false
    @setting = Setting
    # @xlsx = RubyXL::Workbook
    # @allError = Array
    # @sheetcontent_list = Array

    def initialize(skip_error = false)
      @skip_error = skip_error
      @setting = Setting

      FileUtils.mkdir_p(File.dirname(@setting.xlsxpath))
      FileUtils.rm(@setting.xlsxpath) if File.exist? @setting.xlsxpath

      keystrwithColNo = ParseXLSXModule::KeyStrWithColNo.new(@setting.keystr, 0)
      langwithColNolist = Array.new
      colno = 1

      @setting.langlist.each do |key, langinfo|
        langwithColNo = ParseXLSXModule::LangWithColNo.new(langinfo[:xlsheader], key, colno)
        colno+=1
        langwithColNolist.push(langwithColNo)
      end

      if @setting.platform == Platform::IOS
        result = self.parseIOS()
        writeToXlSX(@setting.xlsxpath, keystrwithColNo, langwithColNolist, result[:errorlist], result[:content], result[:keylist])
      else
        result = self.parseAndroid()
        writeToXlSX(@setting.xlsxpath, keystrwithColNo, langwithColNolist, result[:errorlist], result[:content], result[:keylist])
      end


    end

    def parseIOS()
      result = ParseStringsFile.new()
      errorlist = result.errorlist
      content = result.strings_keys
      keylist = result.keys_list
      return {:errorlist => errorlist, :content => content, :keylist => keylist}
    end

    def parseAndroid()
      result = ParseXMLFile.new()
      errorlist = result.errorlist
      content = result.strings_keys
      keylist = result.keys_list
      return {:errorlist => errorlist, :content => content, :keylist => keylist}
    end

    def writeToXlSX(path, keystrwithColNo, langwithColNolist, errorlist, content, keylist)
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
        if !content[key].nil?
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