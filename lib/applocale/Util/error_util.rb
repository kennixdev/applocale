require 'colorize'

module Applocale
  module ErrorUtil
    class CommonError < StandardError
      def raise
        puts "** Error: #{self.message}".red
        abort('')
      end

      def to_warn
        puts "** Warning: #{self.message}".yellow
      end
    end

    class CommandError < CommonError;
    end

    class MissingConfigFile < CommonError
      def message
        "Missing ConfigFile"
      end
    end

    class ConfigFileInValid < CommonError
      def self.raiseArr(list = nil)
        if !list.nil? && list.length > 0
          puts "*** ConfigError ***".red
          list.each do |err|
            puts "#{err.message}".red
          end
          abort("")
        end
      end
    end

    class DownloadFromGoogleFail < CommonError
      def message
        "Cannot download from google"
      end
    end

    class CannotOpenXlsxFile < CommonError
      attr_accessor :path
      def initialize(path)
        @path = path
      end
      def message
        "Can't open xlsx file #{self.path}"
      end
    end
  end
end

module Applocale
  module ErrorUtil

    module ParseXlsxError
      class ParseError < CommonError

        attr_accessor :rowinfo

        def initialize(rowinfo = nil)
          @rowinfo = rowinfo
        end

        def message
          self.msg
        end

        def msg
          return rowinfo.to_s
        end

        def self.raiseArr(list = nil)
          if !list.nil? && list.length > 0
            puts "*** ParseError ***".red
            list.each do |err|
              puts "#{err.message}".red
            end
            abort("")
          end
        end

      end

      class HeadeNotFound < ParseError
        attr_accessor :sheetname
        def initialize(sheetname)
          @sheetname = sheetname
        end

        def message
          "Header not found in sheet: #{self.sheetname}"
        end
      end

      class DuplicateKey < ParseError
        attr_accessor :duplicate_sheetname, :duplicate_rowno

        def initialize(rowinfo, duplicate_sheetname, duplicate_rowno)
          @rowinfo = rowinfo
          @duplicate_sheetname = duplicate_sheetname
          @duplicate_rowno = duplicate_rowno
        end

        def message
          "DuplicateKey [#{self.rowinfo.key_str}] - #{self.msg} : duplicateWithSheet: #{self.duplicate_sheetname} Row: #{self.duplicate_rowno+1}"
        end
      end

      class InValidKey < ParseError;
        def message
          "InvalidKey [#{self.rowinfo.key_str}] - #{self.msg}"
        end
      end
    end
  end
end


module Applocale
  module ErrorUtil

    module ParseLocalizedError
      class ParseLocalizedError < CommonError
        attr_accessor :file, :lang, :row_no

        def initialize(file, lang, row_no)
          @file = file
          @lang = lang
          @row_no = row_no
        end

        def message
          self.msg
        end

        def msg
          return "lang: #{self.lang}, rowno: #{self.row_no}, file: #{self.file}"
        end

        def raise(is_exit = true)
          puts "** Error: #{self.message}".red
          abort("") if is_exit
        end

        def self.raiseArr(list = nil, is_exit = true)
          if !list.nil? && list.length > 0
            puts "*** ParseLocalizedError ***".red
            list.each do |err|
              puts "#{err.message}".red
            end
            abort("") if is_exit
          end
        end

      end

      class InvalidFile < ParseLocalizedError
        attr_accessor :path
        def initialize(path)
          @path = path
        end
        def message
          "Can't open file #{self.path}"
        end
      end

      class InvalidKey < ParseLocalizedError
        attr_accessor :key

        def initialize(key, file, lang, row_no)
          @key = key
          @file = file
          @lang = lang
          @row_no = row_no
        end

        def message
          "InvalidKey [#{self.key}] - #{self.msg}"
        end
      end

      class WrongFormat < ParseLocalizedError;
        def message
          "WrongFormat - #{self.msg}"
        end
      end
      class DuplicateKey < ParseLocalizedError
        attr_accessor :key, :duplicate_rowno

        def initialize(key, duplicate_rowno, file, lang, row_no)
          @key = key
          @duplicate_rowno = duplicate_rowno
          @file = file
          @lang = lang
          @row_no = row_no
        end

        def message
          "DuplicateKey [#{self.key}] - #{self.msg} : duplicateWithRow: #{self.duplicate_rowno}"
        end
      end
    end
  end
end