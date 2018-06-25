require File.expand_path('../../setting.rb', __FILE__)
require File.expand_path('../../../Util/error_util.rb', __FILE__)
require File.expand_path('../../../Util/regex_util.rb', __FILE__)
require File.expand_path('../../ParseModel/parse_model_module.rb', __FILE__)

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
      @platform = platfrom
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
      @sheetcontent_list = @sheetobj_list.map do |sheet_obj|
        sheet_name = sheet_obj.sheetname
        sheet_content = ParseModelModule::SheetContent.new(sheet_name)

        csv_path = File.expand_path("#{sheet_name}.csv", @csv_directory)
        unless File.exist? csv_path
          ErrorUtil.warning("File does not exist: #{csv_path}")
          next
        end
        rows = CSV.read(csv_path)
        header = find_header(sheet_obj, rows)
        sheet_content.header_rowno = header[:header_row_index]
        sheet_content.keyStr_with_colno = header[:key_header_info]
        sheet_content.lang_with_colno_list = header[:language_header_list]

        rows.each_with_index do |row, index|
          next if sheet_content.header_rowno == index
          row_content = parse_row(sheet_name, index, row, sheet_content.keyStr_with_colno, sheet_content.lang_with_colno_list)
          handle_duplicate_key_if_any!(row_content)
          sheet_content.rowinfo_list.push(row_content)
        end
        sheet_content
      end
    end

    def result
      @sheetcontent_list
    end

    def find_header(sheet, rows)
      sheet_name = sheet.sheetname
      sheet_info_obj = sheet.obj
      sheet_language_list = sheet_info_obj.lang_headers
      sheet_key_header = sheet_info_obj.key_header

      header_row_index = rows.index do |row|
        row.include?(sheet_key_header)
      end

      header_row_info = rows[header_row_index] unless header_row_index.nil?
      header_column_index = header_row_info&.index { |cell| cell == sheet_key_header }
      if header_row_index.nil? || header_column_index.nil?
        raise "ParseCSVError: Header not found in sheet #{sheet_name}"
      end
      key_header_info = ParseModelModule::KeyStrWithColNo.new(sheet_key_header, header_column_index)

      language_header_list = sheet_language_list.map do |key, value|
        cell_index = header_row_info.index { |cell| cell == value }
        cell_index.nil? ? nil : ParseModelModule::LangWithColNo.new(value, key, cell_index)
      end.compact
      unless language_header_list.length == sheet_language_list.length
        raise "ParseCSVError: Wrong language keys in sheet #{sheet_name}"
      end
      {
        header_row_index: header_row_index,
        key_header_info: key_header_info,
        language_header_list: language_header_list
      }
    end

    def parse_row(sheet_name, index, row, key_header_info, language_header_list)
      key_str = row[key_header_info.colno]

      unless ValidKey.is_validkey(@platform, key_str)
        raise "ParseCSVError: Invaild Key in sheet #{sheet_name}, row: #{index}, key_str: #{key_str}"
      end
      rowinfo = ParseModelModule::RowInfo.new(sheet_name, index, key_str)
      language_header_list.each do |language_header|
        value = row[language_header.colno] || ''
        # TODO: is it needed?
        value = ContentUtil.from_excel(value)
        rowinfo.content_dict[language_header.lang] = value
      end
      rowinfo
    end

    def handle_duplicate_key_if_any!(row_content)
      previous_row_content = @allkey_dict[row_content.key_str.downcase]
      if previous_row_content.nil?
        @allkey_dict[row_content.key_str.downcase] = row_content
      else
        raise "ParseCSVError:: Duplicate keys:\n sheet #{row_content.sheetname}, row: #{row_content.rowno}, key_str: #{row_content.key_str}\nduplicateWithSheet: #{previous_row_content.sheetname}, row: #{previous_row_content.rowno}, key_str: #{previous_row_content.key_str}"
      end
    end
  end
end
