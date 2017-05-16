require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../../Util/platform.rb', __FILE__)
require File.expand_path('../../Util/regex_util.rb', __FILE__)
require 'colorize'

module Applocale
  class ConvertToStrFile

    def self.convert(sheetcontent_list, setting = Setting)
      setting.langlist.each do |lang, langinfo|
        puts "Start to convert to string file for [\"#{lang}\"] #{langinfo[:path]}...".green
        if setting.platform == Platform::IOS
          self.convert_to_localefile(setting.platform, lang, langinfo[:path], sheetcontent_list)
        elsif setting.platform == Platform::ANDROID
          self.convert_to_xml(setting.platform, lang, langinfo[:path], sheetcontent_list)
        end
      end
      puts 'Convert Finished !!!'.green
    end

    def self.convert_to_localefile(platform, lang, langfilepath, sheetcontent_list)
      FileUtils.mkdir_p(File.dirname(langfilepath))
      target = open(langfilepath, 'w')
      sheetcontent_list.each do |sheetcontent|
        contentlist = sheetcontent.get_rowInfo_sortby_key
        next if contentlist.length <= 0
        target.puts('/*******************************')
        target.puts(" *   #{sheetcontent.comment}")
        target.puts(' *******************************/')
        target.puts('')
        contentlist.each do |rowinfo|
          content = rowinfo.content_dict[lang]
          value = ContentUtil.add_escape(platform, content)
          target.puts("\"#{rowinfo.key_str}\" = \"#{value}\";")
        end
        target.puts('')
      end
      target.close
    end

    def self.convert_to_xml(platform, lang, langfilepath, sheetcontent_list)
      FileUtils.mkdir_p(File.dirname(langfilepath))
      target = open(langfilepath, 'w')
      target.puts('<resources>')
      sheetcontent_list.each do |sheetcontent|
        target.puts("   <!-- #{sheetcontent.comment} -->")
        contentlist = sheetcontent.get_rowInfo_sortby_key
        contentlist.each do |rowinfo|
          content = rowinfo.content_dict[lang]
          value = ContentUtil.add_escape(platform, content)
          target.puts("   <string name=\"#{rowinfo.key_str.downcase}\">#{value}</string>")
        end
        target.puts('')
      end
      target.puts('</resources>')
      target.close
    end

  end
end
