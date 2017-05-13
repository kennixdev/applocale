require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../../Util/platform.rb', __FILE__)
require File.expand_path('../../Util/color_util.rb', __FILE__)
require File.expand_path('../../Util/regex_util.rb', __FILE__)

module Applocale
  class ConvertToStrFile

    def self.convert(sheetcontent_list, setting = Setting)
      setting.langlist.each do |lang, langinfo|
        puts "Start to convert to string file for [\"#{lang}\"] #{langinfo[:path]}...".green
        if setting.platform == Platform::IOS
          self.convertToStrings(setting.platform, lang, langinfo[:path], sheetcontent_list)
        elsif setting.platform == Platform::ANDROID
          self.convertToXML(setting.platform,lang, langinfo[:path], sheetcontent_list)
        end
      end

      puts "Convert Finished !!!".green
    end

    def self.convertToStrings(platform, lang, langfilepath, sheetcontent_list)
      FileUtils.mkdir_p(File.dirname(langfilepath))
      target = open(langfilepath, 'w')

      sheetcontent_list.each do |sheetcontent|
        target.puts("/*******************************")
        target.puts(" *   #{sheetcontent.comment}")
        target.puts(" *******************************/")
        target.puts("")
        contentlist = sheetcontent.getRowInfoSortByKey()
        contentlist.each do |rowinfo|
          content = rowinfo.content_dict[lang]
          value = ContentUtil.addEscape(platform,content)
          target.puts("\"#{rowinfo.key_str.downcase}\" = \"#{value}\";")
        end
        target.puts("")
      end
      target.close

    end

    def self.convertToXML(platform, lang, langfilepath, sheetcontent_list)
      FileUtils.mkdir_p(File.dirname(langfilepath))
      target = open(langfilepath, 'w')
      target.puts("<resources>")

      sheetcontent_list.each do |sheetcontent|
        target.puts("   <!-- #{sheetcontent.comment} -->")
        contentlist = sheetcontent.getRowInfoSortByKey()
        contentlist.each do |rowinfo|
          content = rowinfo.content_dict[lang]
          value = ContentUtil.addEscape(platform,content)
          target.puts("   <string name=\"#{rowinfo.key_str.downcase}\">#{value}</string>")
        end
        target.puts("")
      end

      target.puts("</resources>")
      target.close
    end

  end
end

# attr_accessor :link, :platform, :keystr, :langlist, :langfilepathlist, :xlsxpath
