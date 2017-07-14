
module FindStrKey
  class FindStrKeyObj
    attr_accessor :value, :file, :line
    def initialize(value, file, line)
      self.value = value
      self.file = file
      self.line = line
    end
  end
end

module FindStrKey
  class FindValue
    attr_accessor :key
    def initialize(key)
      self.key = key
    end

    def find(path)
      arrOfObj = Array.new
      files = Dir.glob("#{path}/**/*.{swift}")
      files.each do |file|
        if /^Pods\/|\/Pods\//.match(file)
          next
        end
        puts file
        # # next if file != "HSBC_StockTrading_iOS/Analytic/Tracker.swift"
        arr = findInFile(file)
        arrOfObj.concat arr
      end
      resultInPureKey, result = groupResult(arrOfObj)
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
  end
end

# # local = "/Users/kennix.chui/Documents/Development/GT/HSBC_StockTrading_iOS"
# # find = Applocale::FindStrKey.new()
# # find.find("localizedStringWithKey",local )
#
#
# # def parse_token(line)
# #   n = 0
# #   in_value = false
# #   in_quote = false
# #   in_escape = false
# #   value = ""
# #   num_open = 0
# #
# #   for ch in line.chars
# #     prech = ""
# #     prech = line.chars[n-1] if n > 0
# #     n += 1
# #
# #     if not in_value
# #       if ch == "\""
# #         in_quote = true
# #         in_value = true
# #       elsif ch != " " and ch != "\t"
# #         in_value = true
# #         value << ch
# #       end
# #       next
# #     end
# #
# #     if in_escape
# #       value << prech
# #       value << ch
# #       in_escape = false
# #     elsif ch == "\\"
# #       in_escape = true
# #     elsif in_quote
# #       if ch == "\""
# #         in_quote = false
# #       else
# #         value << ch
# #       end
# #     else
# #       if ch == "("
# #         num_open += 1
# #       elsif ch == ")"
# #         if num_open <= 0
# #           break
# #         end
# #         num_open -= 1
# #       end
# #     end
# #   end
# #   value = ""
# #   if line.chars.length > 1
# #     value = line[0..n-2]
# #   end
# #   return value, line[n..-1]
# # end
# #
# # def getValueWithInKey(key,item)
# #   arr = Array.new
# #   regex = /((?:[^\w]+#{key}\()(.*)|^(?:#{key}\()(.*))/
# #   if item.match(regex)
# #     result = item.scan(regex)
# #     result.each do |item2|
# #       if item2[1].to_s.length > 0
# #         value, line = parse_token(item2[1])
# #       else
# #         value, line = parse_token(item2[2])
# #       end
# #       arr.push(value)
# #       if line.length > 0
# #         inarr = getValueWithInKey(key,line)
# #         if inarr.length > 0
# #           arr.concat inarr
# #         end
# #       end
# #       # puts "--#{valule}---"
# #       # puts line
# #       # puts "=========="
# #     end
# #   end
# #   return arr
# # end
# test = Array.new
# test.push("localizedStringWithKey()")
# test.push("localizedStringWithKey(\"test1\")")
# test.push(" localizedStringWithKey(\"test2\")")
# test.push("(localizedStringWithKey(  \"test3\")")
# test.push("{localizedStringWithKey(\"test4\")")
# test.push("=localizedStringWithKey(hh\"test5\")")
# test.push("+localizedStringWithKey(  \"test6\")"  )
# test.push("kklocalizedStringWithKey(  \"test7\")")
# test.push(" localizedStringWithKey(\"test8\"+\"sdd\")")
# test.push(" localizedStringWithKey(  \"test9()\"+\"sdd\")")
# test.push(" localizedStringWithKey(abad10())")
# test.push(" localizedStringWithKey(\"test1\").agsd")
# test.push(" localizedStringWithKey(\"test12\")test asdf localizedStringWithKey(\"test13\")")
# test.push(" localizedStringWithKey(\"testasdf\\(asdf)1\").agsd")
#
# key = 'localizedStringWithKey'
# # lines = test.join("/n")
#
# find = FindStrKey::FindValue.new(key)
#
# result = Array.new
# lineNum = 0
# test.each do |line|
#   lineNum += 1
#   arrOfValue = find.getValueWithInKey(line)
#   if arrOfValue.length > 0
#     arrOfObj = arrOfValue.map { |value| FindStrKey::FindStrKeyObj.new(value,"file",lineNum)}
#     result.concat arrOfObj
#   end
# end
#
# grouded, grouded2 = find.groupResult(result)
# puts grouded
# puts "------"
# puts grouded2
# grouded.keys.each do |akey|
#     ispure = find.isPureValue(akey)
#     puts ispure
# end

# find.
# puts "-"
# test.each do |item|
#   arr = getValueWithInKey(key,item)
#   puts arr
#   puts "-------------"
#   # arr.map { |n|  }
#   regex = /((?:[^\w]+localizedStringWithKey\()(.*)|^(?:localizedStringWithKey\()(.*))/
#   if item.match(regex)
#     result = item.scan(regex)
#     result.each do |item2|
#       if item2[1].to_s.length > 0
#         valule, line = parse_token(item2[1])
#       else
#         valule, line = parse_token(item2[2])
#       end
#       puts "--#{valule}---"
#       puts line
#       puts "=========="
#     end
#   end
# end
#
# line = "testasdf\\(asdf)1"
# puts line
# regex = /\\\(.*\)/
# if line.match(regex)
#   puts 'matched'
# end