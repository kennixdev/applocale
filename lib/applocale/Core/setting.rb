require 'colorize'
# module Applocale
#   class Setting
#     class <<self
#       attr_accessor :link, :platform, :keystr, :langlist, :xlsxpath
#     end
#
#     def self.printlog
#       puts ' In Setting'
#       puts "  link = #{self.link}"
#       puts "  platform = #{self.platform}"
#       puts "  keystr = #{self.keystr}"
#       puts "  langlist = #{self.langlist}"
#       puts "  xlsxpath = #{self.xlsxpath}"
#     end
#
#   end
# end
#

module Applocale
  module Config
    class Setting
      attr_accessor :configfile_pathstr, :link, :platform, :xlsxpath, :google_credentials_path, :lang_path_list, :sheet_obj_list, :rubycode, :export_format, :export_to, :is_skip_empty_key, :injection
      def initialize(configfile_pathstr)
        self.configfile_pathstr = configfile_pathstr
        self.lang_path_list = Array.new
        self.sheet_obj_list = Array.new
      end

      def printlog
        puts ' In Setting'
        puts "  link = #{self.link}"
        puts "  platform = #{self.platform}"
        puts "  xlsxpath = #{self.xlsxpath}"
        puts "  google_credentials_path = #{self.google_credentials_path} "

        puts "  lang_path_list = "
        self.lang_path_list.each do |langpath_obj|
          puts "    #{langpath_obj.to_s}"
        end
        puts "  sheet_obj_list = "
        self.sheet_obj_list.each do |sheet_obj|
          puts "    #{sheet_obj.to_s}"
        end

        puts " export_format: #{export_format}"
        puts " export_to: #{export_to}"
        puts " is_skip_empty_key: #{self.is_skip_empty_key} "
        # puts self.rubycode

      end
    end

    class LangPath
      attr_accessor :lang, :filepath

      def initialize(lang, filepath)
        self.lang = lang
        self.filepath = filepath
      end

      def to_s
        return "#{self.lang}:  #{self.filepath}"
      end
    end

    class Sheet
      attr_accessor :sheetname, :obj

      def initialize(sheetname, obj)
        self.sheetname = sheetname
        self.obj = obj
      end

      def to_s
        return "#{self.sheetname}   #{self.obj.to_s}"
      end


      def self.get_sheetlist(sheet_obj_list)
        return sheet_obj_list.map{ |sheet_obj| sheet_obj.sheetname }
      end

      def self.get_sheetobj_by_sheetname(sheet_obj_list, sheetname)
        sheet_obj_list.each do |sheet_obj|
          if sheet_obj.sheetname == sheetname
            return sheet_obj.obj
          end
        end
        return nil
      end
    end

    class SheetInfoByHeader
      attr_accessor :key_header, :lang_headers

      def initialize(key_header, lang_headers)
        self.key_header = key_header
        self.lang_headers = lang_headers
      end

      def to_s
        return "key_header: #{self.key_header} | headers: #{self.lang_headers.to_s}"
      end
    end

    class SheetInfoByRow
      attr_accessor  :row, :key_col, :lang_cols

      def initialize(row, key_col, lang_cols)
        self.row = row
        self.key_col = key_col
        self.lang_cols = lang_cols
      end

      def to_s
        return "row: #{self.row} | key_col: #{self.key_col} | lang_cols: #{self.lang_cols.to_s}"
      end
    end

  end
end
