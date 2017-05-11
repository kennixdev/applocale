require File.expand_path('../../setting.rb', __FILE__)
require File.expand_path('../../../Util/error_util.rb', __FILE__)
require File.expand_path('../../../Util/regex_util.rb', __FILE__)

module Applocale
  class ParseStringsFile

    attr_reader :strings_keys, :errorlist, :in_multiline_comments, :keys_list, :platform

    def initialize()
      @strings_keys = {}
      @keys_list = Array.new
      @errorlist = Array.new()
      @platform = Setting.platform
      self.to_parse_files(Setting.langlist)
    end

    def to_parse_files(lang_list)
      lang_list.each do |key, langinfo|
        self.to_parse_strings_file(key, langinfo[:path])
      end
    end

    def to_parse_strings_file(lang, strings_path)
      puts "Start to Parse strings file: \"#{strings_path}\" ...".green

      @in_multiline_comments = false
      keyrowno = {}
      linenum = 0
      IO.foreach(strings_path, mode: 'r:bom|utf-8') {|line|
        linenum += 1
        line.strip!
        if !@in_multiline_comments
          next if line.start_with?('#')
          next if line.start_with?('//')
        end
        if line.length <= 0
          next
        end
        while true

          key, line = parse_token(linenum, line, "=", lang, strings_path)
          line.strip!

          if not line.start_with?("=")
            if !@in_multiline_comments && line.length > 0
              error = ErrorUtil::ParseLocalizedError::WrongFormat.new(strings_path, lang, linenum)
              @errorlist.push(error)
            end
            break
          end
          line.slice!(0)

          value, line = parse_token(linenum, line, ";", lang, strings_path)
          line.strip!

          if line.start_with?(";")
            line.slice!(0)
          else
            error = ErrorUtil::ParseLocalizedError::WrongFormat.new(strings_path, lang, linenum)
            @errorlist.push(error)
            key = nil
            value = nil
            break
          end

          if !ValidKey.isValidKey(@platform, key)
            error = ErrorUtil::ParseLocalizedError::InvalidKey.new(key, strings_path, lang, linenum)
            @errorlist.push(error)
            break
          end
          if @strings_keys[key].nil?
            @strings_keys[key] = Hash.new
            @keys_list.push(key)
          end
          if @strings_keys[key][lang.to_s].nil?
            @strings_keys[key][lang.to_s] = Hash.new
            @strings_keys[key][lang.to_s][:rowno] = linenum
            @strings_keys[key][lang.to_s][:value] = ContentUtil.removeEscape(@platform, value)
            keyrowno[key] = linenum
          else
            error = ErrorUtil::ParseLocalizedError::DuplicateKey.new(key, keyrowno[key], strings_path, lang, linenum)
            @errorlist.push(error)
          end
          if line.length <= 0
            break
          end
        end
      }
    end

    def parse_token(linenum, line, sep, lang, file)
      n = 0
      in_value = false
      in_quote = false
      in_escape = false
      value = ""

      for ch in line.chars
        prech = ""
        prech = line.chars[n-1] if n > 0
        n += 1
        if @in_multiline_comments
          if "#{prech}#{ch}" == "*/"
            @in_multiline_comments = false
            in_value = false
            value = ""
          end
          next
        end

        if not in_value
          if ch == "\""
            in_quote = true
            in_value = true
          elsif ch != " " and ch != "\t" and ch != sep
            in_value = true
            value << ch
          end
          next
        end

        if in_escape
          value << prech
          value << ch
          in_escape = false
        elsif ch == "\\"
          in_escape = true
        elsif in_quote
          if ch == "\""
            break
          else
            value << ch
          end
        else
          if ch == " " or ch == "\t" or ch == sep
            n -= 1
            break
          elsif "#{prech}#{ch}" == "/*"
            @in_multiline_comments = true
          elsif "#{prech}#{ch}" == "//"
            return value, ""
          elsif ch == "#"
            return value, ""
          elsif "#{prech}#{ch}".length > 1
            error = ErrorUtil::ParseLocalizedError::WrongFormat.new(file, lang, linenum)
            @errorlist.push(error)
            return value, ""
          else
            value << ch
          end
        end
      end
      return value, line[n..-1]
    end
  end
end