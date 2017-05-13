require 'colorize'
require File.expand_path('../platform.rb', __FILE__)


module Applocale
  class ValidKey
    REGEX_KEYSTR_IOS = /\A[0-9a-zA-Z\_]+\z/

    def self.isValidKey(platfrom, key)
      return false if key.nil?
      return false if key.strip == ""
      result = !REGEX_KEYSTR_IOS.match(key).nil?
      return result
    end
  end

  class ContentUtil
    REGEX_ESCAPED_QUOTE = /(?<!\\)(?:\\{2})*(\\")/
    REGEX_NON_ESCAPE_QUOTE = /(?<!\\)(?:\\{2})*(")/

    def self.removeEscape(platform, content)
      if platform == Platform::IOS
        return self.removeEscapedDoubleQuote(content)
      elsif platform == Platform::ANDROID
        return self.removeEscapedForAndroid(content)
      end
      return content
    end

    def self.addEscape(platform, content)
      if platform == Platform::IOS
        return self.addEscapedDoubleQuote(content)
      elsif platform == Platform::ANDROID
        return self.addEscapedForAndroid(content)
      end
      return content
    end

    def self.addEscapedForAndroid(content)
      # \u \U \0 don't know
      reg = /(?<!\\)((?:\\{2})+)*\\[c-eg-mo-qsw-zA-TW-Z!$%()*+,-.\/;:>\[\]^_`{|}~89]/
      new_value = content.gsub(reg) {|match|
        match.slice!(0)
        match
      }
      reg = /(?<!\\)((?:\\{2})+)*(\\r)/
      new_value = new_value.gsub(reg) {|match|
        match.slice!(-1)
        match + "n"
      }
      new_value = new_value.gsub(/&/, "&amp;")
      new_value = new_value.gsub(/</, "&lt;")
      # new_value = new_value.gsub(/>/, "&gt;")
      return new_value
    end

    def self.removeEscapedForAndroid(content)
      new_value = content.gsub(/&lt;/, "<")
      new_value = new_value.gsub(/&amp;/, "&")
      puts "test=#{content}==#{new_value}"
      return new_value
    end

    def self.addEscapedDoubleQuote(content)
      reg = /(?<!\\)((?:\\{2})+)"|(?<!\\)"|^"/
      new_value = content.gsub(reg) {|match|
          "\\" + match
      }
      return new_value
    end

    def self.removeEscapedDoubleQuote(content)
      reg = /(?<!\\)((?:\\{2})+)*\\"/
      new_value = content.gsub(reg) {|match|
        match.slice!(0)
        match
      }
      return new_value
    end

  end
end

# test = "aasb\\c"
# new = test.slice(-1)
# test.slice!(-2)
# puts test
# puts new

# ex = "\\"
# qu = "&"
#
# (0..10).each do |i|
#   test = ([ex]*i).join("") + qu + "abcd" + ([ex]*i).join("") + qu + "def"
#   puts "#{test}"
#   puts Applocale::ContentUtil.addEscapedForAndroid(test)
#   puts "------------------------------------"
# end


#
# #
# #
# # test = qu
# # test1 = ex + qu
# # test2 = ex + ex + qu
# # test3 = ex + ex + ex + qu
# # test4 = ex + ex + ex + ex + qu
# #
# # Applocale::ContentUtil.removeEscapeFroXlsx(test)