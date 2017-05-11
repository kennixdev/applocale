require 'colorize'


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
      return content
      # return content if content.nil?
      # newvalue = content.gsub(/\\"/, "\"")
      # newvalue = newvalue.gsub(/\\\\/, "\\")
      # return newvalue
    end

    def self.addEscape(platform, content)
      return content
      # return content if content.nil?
      # newvalue = content.gsub(/\\/, "\\\\\\")
      # newvalue = newvalue.gsub(/\"/, "\\\"")
      # return newvalue
    end
   end
end
