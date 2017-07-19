require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../../Util/platform.rb', __FILE__)
require File.expand_path('../../Util/regex_util.rb', __FILE__)
require 'colorize'

module Applocale
  class ConvertToStrFile

    def self.convert(platform, lang_path_list, sheetcontent_list)
      lang_path_list.each do |langpath_obj|
        puts "Start to convert to string file for [\"#{langpath_obj.lang}\"] #{langpath_obj.filepath}...".green
        if platform == Platform::IOS
          self.convert_to_stringfile(platform, langpath_obj, sheetcontent_list)
        elsif platform == Platform::ANDROID
          self.convert_to_xml(platform, langpath_obj, sheetcontent_list)
        end
      end
      puts 'Convert Finished !!!'.green
    end

    def self.convert_to_stringfile(platform, langpath_obj, sheetcontent_list)
      FileUtils.mkdir_p(File.dirname(langpath_obj.filepath))
      target = open(langpath_obj.filepath, 'w')
      sheetcontent_list.each do |sheetcontent|
        contentlist = sheetcontent.get_rowInfo_sortby_key
        next if contentlist.length <= 0
        target.puts('/*******************************')
        target.puts(" *   #{sheetcontent.comment}")
        target.puts(' *******************************/')
        target.puts('')
        contentlist.each do |rowinfo|
          content = rowinfo.content_dict[langpath_obj.lang]
          value = ContentUtil.add_escape(platform, content)
          target.puts("\"#{rowinfo.key_str}\" = \"#{value}\";")
        end
        target.puts('')
      end
      target.close
    end

    def self.convert_to_xml(platform, langpath_obj, sheetcontent_list)
      FileUtils.mkdir_p(File.dirname(langpath_obj.filepath))
      target = open(langpath_obj.filepath, 'w')
      target.puts('<resources>')
      sheetcontent_list.each do |sheetcontent|
        target.puts("   <!-- #{sheetcontent.comment} -->")
        contentlist = sheetcontent.get_rowInfo_sortby_key
        contentlist.each do |rowinfo|
          content = rowinfo.content_dict[langpath_obj.lang]
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
