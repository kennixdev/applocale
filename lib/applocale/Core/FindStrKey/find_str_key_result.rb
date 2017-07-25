require File.expand_path('../find_str_key', __FILE__)

require 'rubyXL'
require 'colorize'
require 'pathname'

module FindStrKey
  class GenReport
    DEFAULT_XLSX = 'findkey_result.xlsx'
    DEFAULT_TXT = 'findkey_result.txt'

    attr_accessor :proj_path, :path, :main_result, :second_result

    def initialize(proj_path, path, main_result, second_result)
      self.proj_path = proj_path
      self.path = path
      self.main_result = main_result
      self.second_result = second_result
    end

    def gen_xlsx
      xlsx_path = File.join(self.path, DEFAULT_XLSX)
      File.delete(xlsx_path) if File.exist? xlsx_path
      self.write_to_xlsx(xlsx_path)
    end

    def write_to_xlsx(xlsx_path)
      puts "Start write to file: \"#{xlsx_path}\" ...".green
      workbook = RubyXL::Workbook.new
      worksheet = workbook.worksheets[0]
      rowno = 0
      keycolno = 0
      self.main_result.each do |arrs|
        key = arrs.first.value
        worksheet.add_cell(rowno, keycolno, key)
        rowno += 1
      end
      worksheet.add_cell(rowno, 0, '')
      worksheet.change_row_fill(rowno, 'fffacd')
      rowno += 1
      self.second_result.each do |arrs|
        key = arrs.first.value
        worksheet.add_cell(rowno, keycolno, key)
        rowno += 1
      end
      workbook.write(xlsx_path)
    end

    def gen_txt
      txt_path = File.join(self.path, DEFAULT_TXT)
      File.delete(txt_path) if File.exist? txt_path
      self.write_to_txt(txt_path)
    end

    def write_to_txt(txt_path)
      puts "Start write to file: \"#{txt_path}\" ...".green
      target = open(txt_path, 'w')

      self.main_result.each do |arrs|
        key = arrs.first.value
        target.puts("#{key} : ")
        arrs.each do |obj|
          rpath = Pathname.new(obj.file).relative_path_from(Pathname.new(self.proj_path)).to_s
          target.puts("   line-#{obj.line}:\t#{rpath}")
        end
        target.puts('')
      end
      target.close
    end
  end
end

