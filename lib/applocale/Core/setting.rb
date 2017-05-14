require 'colorize'

module Applocale
  class Setting
    class <<self
      attr_accessor :link, :platform, :keystr, :langlist, :xlsxpath
    end

    def self.printlog
      puts ' In Setting'
      puts "  link = #{self.link}"
      puts "  platform = #{self.platform}"
      puts "  keystr = #{self.keystr}"
      puts "  langlist = #{self.langlist}"
      puts "  xlsxpath = #{self.xlsxpath}"
    end

  end
end
