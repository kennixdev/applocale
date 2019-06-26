require File.expand_path('../../../Util/platform.rb', __FILE__)

module Applocale
  class CompareStringFile

    attr_reader  :in_multiline_comments, :platform, :file1, :file2, :errorlist

    def initialize(platform, file1, file2)
      @platform = platform
      @file1 = file1
      @file12 = file2


      @errorlist = Array.new()
      @platform = platform

      obj1 = {}
      obj2 = {}
      if platform == Platform::IOS
        obj1 = parse_ios_file(file1)
        obj2 = parse_ios_file(file2)
      elsif platform == Platform::ANDROID
        obj1 = parse_aos_file(file1)
        obj2 = parse_aos_file(file2)
      end
      compare(obj1,obj2)
    end


    def compare(obj1, obj2)
      missingkeyInObj2 = Array.new
      mismatch = Array.new
      duplicateKey = Array.new
      notSame = {}
      nobj2 = obj2
      obj1.each do |key, value|
        if nobj2[key].nil?
          missingkeyInObj2.push(key)
        else
          obj1Value = value
          obj2Value = obj2[key]
          if obj1Value.length != obj2Value.length
            mismatch.push(key)
          elsif obj1Value.length != 1
            duplicateKey.push(key)
          elsif obj1Value[0] != obj2Value[0]
            notSame[key] = {obj1: obj1Value[0],obj2: obj2Value[0]}
          end
        end
        nobj2.delete(key)
      end
      puts "==> not Same value:"
      notSame.each do |key, value|
        puts "key = #{key}"
        puts "#{value[:obj1]}<"
        puts "#{value[:obj2]}<"
      end
      puts "==> duplicateKey"
      puts duplicateKey
      puts "==> mismatch"
      puts mismatch
      puts "==> missingkeyInObj2"
      puts missingkeyInObj2
      puts "==> missingKeyInObj1"
      puts nobj2
    end



    def parse_aos_file(strings_path)
      strings_keys = {}

      return if !File.exist? strings_path
      puts "Start to Parse xml file: \"#{strings_path}\" ...".green

      xml_doc = Nokogiri::XML(File.open(strings_path))
      string_nodes = xml_doc.xpath("//string")
      string_nodes.each do |node|
        key = node["name"]
        value = node.content
        if !key.nil? && key.strip.length > 0
          if strings_keys[key].nil?
            strings_keys[key] = Array.new
          end
          strings_keys[key].push(value)

          # if @strings_keys[key].nil?
          #   @strings_keys[key] = Hash.new
          #   @keys_list.push(key)
          # end
          # if @strings_keys[key][lang.to_s].nil?
          #   @strings_keys[key][lang.to_s] = Hash.new
          #   @strings_keys[key][lang.to_s][:value] = self.remove_escape(lang, key, value)
          # else
          #   error = ErrorUtil::ParseLocalizedError::DuplicateKey.new(key, -1, strings_path, lang, -1).raise
          # end
        end
      end
      return strings_keys

    end

    def parse_ios_file(path)
      strings_keys = {}
      @in_multiline_comments = false
      linenum = 0
      begin
      IO.foreach(path, mode: 'r:bom|utf-8') {|line|
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
          key, line = parse_token(linenum, line, "=", path)
          line.strip!

          if not line.start_with?("=")
            if !@in_multiline_comments && line.length > 0
              error = ErrorUtil::ParseLocalizedError::WrongFormat.new(path, "", linenum).raise
            end
            break
          end
          line.slice!(0)

          value, line = parse_token(linenum, line, ";", path)
          line.strip!

          if line.start_with?(";")
            line.slice!(0)
          else
            error = ErrorUtil::ParseLocalizedError::WrongFormat.new(path, "", linenum).raise
            key = nil
            value = nil
            break
          end
          if strings_keys[key].nil?
            strings_keys[key] = Array.new
          end
          strings_keys[key].push(value)
        end
      }
      rescue Exception => e
        puts e.message
        ErrorUtil::ParseLocalizedError::InvalidFile.new(file1).raise
      end

      return strings_keys
    end


    def parse_token(linenum, line, sep, file)
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
            error = ErrorUtil::ParseLocalizedError::WrongFormat.new(file, "", linenum)
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
