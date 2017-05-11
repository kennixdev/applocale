require File.expand_path('../color_util.rb', __FILE__)


module Applocale
  module ErrorUtil
    class CommonError < StandardError
      def raise
        puts "** Error: #{self.message}".red
        abort("")
      end

      def to_warn
        puts "** Warning: #{self.message}".yellow
      end
    end

    class CommandError < CommonError;
    end

    class MissingConfigFileError < CommonError;
    end

    class ConfigFileValidError < CommonError
      def self.raiseArr(list = nil)
        if !list.nil? && list.length > 0
          puts "*** ConfigError ***".red
          list.each do |err|
            puts "#{err.message}".red
          end
          abort("")
        end
      end
      # attr_accessor :msg
      # def initialize(msg)
      #   self.msg = msg
      # end
    end

    class DownloadXlsxError < CommonError

    end


    module ParseXlsxError
      class ParseError < CommonError

        attr_accessor :rowinfo, :msg

        def initialize(rowinfo = nil, msg = nil)
          @rowinfo = rowinfo
          @msg = msg
        end

        def message
          "#{rowinfo.to_s} - #{msg}"
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

      class HeadeNotFoundError < ParseError;
      end
      class ErrorDuplicateKey < ParseError;
      end
      class ErrorInValidKey < ParseError;
      end
    end

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
          return "lang: #{lang}, rowno: #{row_no}, file: #{file}"
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

      class InvalidKey < ParseLocalizedError
        attr_accessor :key

        def initialize(key, file, lang, row_no)
          @key = key
          @file = file
          @lang = lang
          @row_no = row_no
        end

        def message
          "InvalidKey [#{key}] - #{self.msg}"
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
          "DuplicateKey [#{key}] - #{self.msg} : duplicateWithRow: #{duplicate_rowno}"
        end
      end
    end
  end
end