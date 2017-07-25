


module FindStrKey
  class FindValueIOS
    attr_accessor :proj_path, :key
    def initialize( proj_path, key)
      self.proj_path = proj_path
      self.key = key
    end

    def find()
      arrOfObj = Array.new
      files = Dir.glob("#{self.proj_path}/**/*.{swift}")
      files.each do |file|
        if /^Pods\/|\/Pods\//.match(file)
          next
        end
        arr = findInFile(file)
        arrOfObj.concat arr
      end
      resultInPureKey, result = groupResult(arrOfObj)

      keysarr = resultInPureKey.keys.map { |_key| {:key => _key.downcase, :realkey => _key}}
      keys_ordered = keysarr.sort_by {|value|  value[:key]}
      resultInPureKey_ordered = keys_ordered.map{|value| resultInPureKey[value[:realkey]]}

      keysarr = result.keys.map { |_key| {:key => _key.downcase, :realkey => _key}}
      keys_ordered = keysarr.sort_by {|value|  value[:key]}
      result_ordered = keys_ordered.map{|value| result[value[:realkey]]}
      return resultInPureKey_ordered, result_ordered
    end

    def findInFile(file)
      puts "processing #{file}"
      result = Array.new
      lineNum = 0
      lines = IO.readlines(file).map do |line|
        lineNum += 1
        arrOfValue = self.getValueWithInKey(line)
        if arrOfValue.length > 0
          arrOfObj = arrOfValue.map { |value| FindStrKeyObj.new(value,file,lineNum)}
          result.concat arrOfObj
        end
      end
      return result
    end

    def getValueWithInKey(orgline)
      result = Array.new
      regex = /((?:[^\w]+#{self.key}\()(.*)|^(?:#{self.key}\()(.*))/
      if orgline.match(regex)
        matchedArr = orgline.scan(regex)
        matchedArr.each do |matchedValue|
          if matchedValue[1].to_s.length > 0
            value, line = self.parse_token(matchedValue[1])
          else
            value, line = self.parse_token(matchedValue[2])
          end
          if value.strip.length > 0
            result.push(value.strip)
          end
          if line.length > 0
            arr = self.getValueWithInKey(line)
            if arr.length > 0
              result.concat arr
            end
          end
        end
      end
      return result
    end

    def parse_token(line)
      n = 0
      in_value = false
      in_quote = false
      in_escape = false
      value = ""
      num_open = 0

      for ch in line.chars
        prech = ""
        prech = line.chars[n-1] if n > 0
        n += 1

        if not in_value
          if ch == "\""
            in_quote = true
            in_value = true
          elsif ch != " " and ch != "\t"
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
            in_quote = false
          else
            value << ch
          end
        else
          if ch == "("
            num_open += 1
          elsif ch == ")"
            if num_open <= 0
              break
            end
            num_open -= 1
          end
        end
      end
      value = ""
      if line.chars.length > 1
        value = line[0..n-2]
      end
      return value, line[n..-1]
    end



    def groupResult(arrOfObj)
      list = {}
      purekeylist = {}
      arrOfObj.each do |item|
        value = isPureValue(item.value)
        arr = Array.new
        if value.nil?
          value = item.value
          if !list[value].nil?
            arr = list[value]
          end
          arr.push(item)
          list[value] = arr
        else
          item.value = value
          if !purekeylist[value].nil?
            arr = purekeylist[value]
          end
          arr.push(item)
          purekeylist[value] = arr
        end
      end
      return purekeylist, list
    end

    def isPureValue(aline)
      n = 0
      in_value = false
      in_quote = false
      in_escape = false
      value = ""
      line = aline.strip
      for ch in line.chars
        prech = ""
        prech = line.chars[n-1] if n > 0
        n += 1

        if not in_value
          if ch == "\""
            in_quote = true
            in_value = true
          elsif ch != " " and ch != "\t"
            return nil
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
          value << ch
        end
      end
      remained = line[n..-1]
      if remained.strip.length > 0
        return nil
      else
        regex = /\\\(.*\)/
        if line.match(regex)
          return nil
        end
        if line.length > 2
          return line[1..n-2]
        end
      end
      return nil
    end


  end
end
