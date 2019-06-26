require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../../Util/platform.rb', __FILE__)
require File.expand_path('../../Util/regex_util.rb', __FILE__)
require File.expand_path('../../Util/injection.rb', __FILE__)

require 'colorize'
require 'json'

module Applocale
  class ConvertToStrFile


    def self.convert(setting, sheetcontent_list)

      platform = setting.platform
      lang_path_list =  setting.lang_path_list
      injectObj = setting.injection

      lang_path_list.each do |langpath_obj|
        puts "Start to convert to string file for [\"#{langpath_obj.lang}\"] #{langpath_obj.filepath}...".green
        if platform == Platform::IOS
          self.convert_to_stringfile(platform, langpath_obj, sheetcontent_list, injectObj)
        elsif platform == Platform::ANDROID
          self.convert_to_xml(platform, langpath_obj, sheetcontent_list, injectObj)
        elsif platform == Platform::JSON
          self.convert_to_json(platform, langpath_obj, sheetcontent_list, injectObj)
        end
      end
      puts 'Convert Finished !!!'.green
    end

    def self.convert_to_stringfile(platform, langpath_obj, sheetcontent_list, injectObj)
      FileUtils.mkdir_p(File.dirname(langpath_obj.filepath))
      file_header_comment = []
      is_double_dash_comment = false
      is_multiline_comment = false
      if File.file?(langpath_obj.filepath)
        File.open(langpath_obj.filepath, 'r').each do |line|
        if is_double_dash_comment
          break unless line.strip.start_with?('//')
          file_header_comment.push(line)
          next
        end

        if is_multiline_comment
          file_header_comment.push(line)
          break if line.include?('*/')
        end

        unless is_multiline_comment or is_double_dash_comment
          case
          when line.chomp.empty?
            file_header_comment.push(line)
          when line.strip.start_with?('//')
            is_double_dash_comment = true
            file_header_comment.push(line)
          when line.strip.start_with?('/*') && !line.strip.start_with?('/**')
            is_multiline_comment = true
            file_header_comment.push(line)
          else
            break
          end
        end
        end
      end

      target = open(langpath_obj.filepath, 'w')
      target.puts file_header_comment.join('') if is_double_dash_comment or is_multiline_comment
      sheetcontent_list.each_with_index do |sheetcontent, index|
        contentlist = sheetcontent.get_rowInfo_sortby_key
        next if contentlist.length <= 0
        target.puts('') if index > 0 or !file_header_comment.empty?
        target.puts('/*******************************')
        target.puts(" *   #{sheetcontent.comment}")
        target.puts(' *******************************/')
        target.puts('')
        contentlist.each do |rowinfo|
          content = rowinfo.content_dict[langpath_obj.lang]
          value = self.add_escape(platform, langpath_obj.lang, rowinfo.key_str, content, injectObj)
          target.puts("\"#{rowinfo.key_str}\" = \"#{value}\";")
        end
      end
      target.close
    end

    def self.convert_to_xml(platform, langpath_obj, sheetcontent_list, injectObj)
      FileUtils.mkdir_p(File.dirname(langpath_obj.filepath))
      target = open(langpath_obj.filepath, 'w')
      target.puts('<resources>')
      sheetcontent_list.each do |sheetcontent|
        target.puts("   <!-- #{sheetcontent.comment} -->")
        contentlist = sheetcontent.get_rowInfo_sortby_key
        contentlist.each do |rowinfo|
          content = rowinfo.content_dict[langpath_obj.lang]
          value = self.add_escape(platform, langpath_obj.lang, rowinfo.key_str, content, injectObj)
          target.puts("   <string name=\"#{rowinfo.key_str}\">#{value}</string>")
        end
        target.puts('')
      end
      target.puts('</resources>')
      target.close
    end

    def self.convert_to_json(platform, lang_path_obj, sheet_content_list, inject_obj)
      FileUtils.mkdir_p(File.dirname(lang_path_obj.filepath))
      hash = sheet_content_list.map do |sheet_content|
        newResult = sheet_content.get_rowInfo_sortby_key.map do |row|
          content = ContentUtil.remove_escaped_new_line(row.content_dict[lang_path_obj.lang])
          value = add_escape(platform, lang_path_obj.lang, row.key_str, content, inject_obj)
          [row.key_str, value]
        end.to_h
        newResult
      end.reduce({}, :merge)
      section_last_row = sheet_content_list
                             .map {|sheet_content| sheet_content.get_rowInfo_sortby_key.last.key_str }
                             .compact
                             .reverse
                             .drop(1)
                             .reverse
      json = JSON.pretty_generate(hash)
      section_last_row.each { |row| json.gsub!(/(.*)("#{row}")(.*)/, '\1\2\3' + "\n") }
      target = open(lang_path_obj.filepath, 'w')
      target.puts(json)
      target.close
    end

    def self.add_escape(platform, lang, key, content, injectObj)
      value = content
      if injectObj.has_before_convent_to_locale
        value = injectObj.load_before_convent_to_locale(lang.to_s, key,  value)
      end
      if injectObj.has_convent_to_locale
        tvalue = injectObj.load_convent_to_locale(lang.to_s, key,  value)
        if !tvalue.nil?
          value = tvalue
        end
      else
        value = ContentUtil.add_escape(platform, value)
      end
      if injectObj.has_after_convent_to_locale
        value = injectObj.load_after_convent_to_locale(lang.to_s, key,  value)
      end
      return value
    end

  end
end
