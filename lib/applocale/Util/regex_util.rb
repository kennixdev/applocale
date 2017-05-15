require 'colorize'
require File.expand_path('../platform.rb', __FILE__)


module Applocale
  class ValidKey
    REGEX_KEYSTR_IOS = /\A[0-9a-zA-Z_]+\z/

    def self.is_validkey(platfrom, key)
      return false if key.nil?
      return false if key.strip.length <= 0
      result = !REGEX_KEYSTR_IOS.match(key).nil?
      return result
    end
  end

  class ContentUtil
    REGEX_ESCAPED_QUOTE = /(?<!\\)(?:\\{2})*(\\")/
    REGEX_NON_ESCAPE_QUOTE = /(?<!\\)(?:\\{2})*(")/

    def self.remove_escape(platform, content)
      if platform == Platform::IOS
        return self.remove_escaped_double_quote(content)
      elsif platform == Platform::ANDROID
        return self.remove_escaped_android(content)
      end
      return content
    end

    def self.add_escape(platform, content)
      if platform == Platform::IOS
        return self.add_escaped_double_quote(content)
      elsif platform == Platform::ANDROID
        return self.add_escaped_android(content)
      end
      return content
    end

    def self.add_escaped_android(content)
      # \u \U \0 don't know
      reg = /(?<!\\)((?:\\{2})+)*\\[c-eg-mo-qsw-zA-TW-Z!$%()*+,-.\/;:>\[\]^_`{|}~89]/
      new_value = content.gsub(reg) {|match|
        match.slice!(0)
        match
      }
      reg = /(?<!\\)((?:\\{2})+)*(\\r)/
      new_value = new_value.gsub(reg) {|match|
        match.slice!(-1)
        match + 'n'
      }
      new_value = new_value.gsub(/&/, '&amp;')
      new_value = new_value.gsub(/</, '&lt;')
      # new_value = new_value.gsub(/>/, "&gt;")
      return new_value
    end

    def self.remove_escaped_android(content)
      new_value = content.gsub(/&lt;/, '<')
      new_value = new_value.gsub(/&amp;/, '&')
      puts "test=#{content}==#{new_value}"
      return new_value
    end

    def self.add_escaped_double_quote(content)
      reg = /(?<!\\)((?:\\{2})+)"|(?<!\\)"|^"/
      new_value = content.gsub(reg) {|match|
          "\\" + match
      }
      return new_value
    end

    def self.remove_escaped_double_quote(content)
      reg = /(?<!\\)((?:\\{2})+)*\\"/
      new_value = content.gsub(reg) {|match|
        match.slice!(0)
        match
      }
      return new_value
    end

    def self.from_excel(content)
      reg = /(?<!\\)((?:\\{2})+)*\\"/
      new_value = content.gsub(reg) {|match|
        match.slice!(0)
        match
      }
      new_value = new_value.gsub(/\n/, "\\n")
      new_value = new_value.gsub(/\t/, "\\t")
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