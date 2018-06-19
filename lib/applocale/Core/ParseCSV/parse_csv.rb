require File.expand_path('../../setting.rb', __FILE__)
require File.expand_path('../../../Util/error_util.rb', __FILE__)
require File.expand_path('../../../Util/regex_util.rb', __FILE__)

require 'colorize'
require 'csv'

module Applocale
  class ParseCSV

    @sheetcontent_list = nil
    @allkey_dict = {}
    @all_error = nil

    @platform
    @csv_directory
    @langlist
    @sheetobj_list

    def initialize(platfrom, csv_directory, langlist, sheetobj_list)
      @platform = csv_directory
      @csv_directory = csv_directory
      @langlist = langlist
      @sheetobj_list = sheetobj_list
      @sheetcontent_list = Array.new
      @allkey_dict = {}
      @all_error = Array.new
      # puts "Start to Parse CSV: \"#{csv_directory}\" ...".green
      parse
    end

    def parse

      @sheetobj_list.each do |sheet_obj|
        sheet_name = sheet_obj.sheetname
        sheet_info_obj = sheet_obj.obj

        sheet_content = ParseXLSXModule::SheetContent.new(sheet_name)
        # keycolno = Applocale::ParseXLSXModule::Helper.collabel_to_colno(sheetinfoobj.key_col)
        # sheet_info_obj.to_keyStrWithColNo(sheet_content)

        csv_path = File.expand_path("#{sheet_name}.csv", @csv_directory)
        unless File.exist? csv_path
          ErrorUtil.warning("File does not exist: #{csv_path}")
          next
        end
        CSV.foreach(csv_path) do |row|
          # p row
        end
      end
    end
  end
end
