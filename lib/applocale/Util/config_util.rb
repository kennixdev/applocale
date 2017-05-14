require 'yaml'
require File.expand_path('../file_util.rb', __FILE__)
require File.expand_path('../error_util.rb', __FILE__)
require File.expand_path('../platform.rb', __FILE__)
require File.expand_path('../../Core/setting.rb', __FILE__)

require 'pathname'

module Applocale
  class ConfigUtil
    def self.create_configfile_ifneed(platform)
      pathstr = FileUtil.configfile_pathstr
      self.create_configfile(platform, pathstr) unless File.exist?(pathstr)
    end

    def self.create_configfile(platform, configfile_pathstr)
      src_pathstr = File.expand_path("../../#{FileUtil.filename_config}", __FILE__)

      File.open(src_pathstr, 'r') do |form|
        File.open(configfile_pathstr, 'w') do |to|
          form.each_line do |line|
            newline = line.gsub("\#{platform}", "#{platform.to_s}")
            newline = newline.gsub("\#{path_zh_TW}", FileUtil.get_default_localefile_relative_pathstr(platform, Locale::ZH_TW))
            newline = newline.gsub("\#{path_zh_CN}", FileUtil.get_default_localefile_relative_pathstr(platform, Locale::ZH_CN))
            newline = newline.gsub("\#{path_en_US}", FileUtil.get_default_localefile_relative_pathstr(platform, Locale::EN_US))
            newline = newline.gsub("\#{xlsxpath}", FileUtil.get_default_xlsx_relativepath_str)
            to.puts(newline)
          end

        end
      end
    end

    def self.load_and_validate_xlsx_to_localefile(is_local_update)
      config_yaml = self.load_config
      self.validate_xlsx_to_localefile(config_yaml, is_local_update)
    end

    def self.load_and_validate_localefile_to_xlsx()
      config_yaml = self.load_config
      self.validate_localefile_to_xlsx(config_yaml)
    end

    # private
    def self.load_config
      configfile_path = FileUtil.configfile_pathstr
      unless File.exist?(configfile_path)
        ErrorUtil::MissingConfigFile.new.raise
      end
      begin
        config_yaml = YAML.load_file configfile_path
      rescue
        ErrorUtil::ConfigFileInValid.new('ConfigFile format is invalid.').raise
      end
      return config_yaml
    end

    def self.validate_xlsx_to_localefile(config_yaml, is_local_update)
      error_list = self.validate_common(config_yaml)
      if is_local_update
        unless File.exist? Setting.xlsxpath
          error = ErrorUtil::ConfigFileInValid.new("#{Setting.xlsxpath} do not exist")
          error_list.push(error)
        end
      else
        if config_yaml['link'].to_s.strip.nil? || config_yaml['link'].to_s.strip.length <= 0
          error = ErrorUtil::ConfigFileInValid.new('[link] should not be empty')
          error_list.push(error)
        end
      end
      ErrorUtil::ConfigFileInValid.raiseArr(error_list)
    end

    def self.validate_localefile_to_xlsx(config_yaml)
      error_list = self.validate_common(config_yaml)
      Setting.langlist.each do |_, langinfo|
        unless File.exist? langinfo[:path]
          error = ErrorUtil::ConfigFileInValid.new("#{langinfo[:path]} do not exist")
          error_list.push(error)
        end
      end
      ErrorUtil::ConfigFileInValid.raiseArr(error_list)
    end

    def self.validate_common(config_yaml)
      error_list = Array.new
      link = config_yaml['link'].to_s.strip
      platform = config_yaml['platform'].to_s.strip
      keystr = config_yaml['keystr'].to_s.strip
      langlist = config_yaml['langlist']
      xlsxpath = config_yaml['xlsxpath'].to_s.strip

      newlink = nil
      newplatform = nil
      newkeystr = nil
      newlanglist = Hash.new
      newxlsxpath = nil

      unless link.nil? || link.length == 0
        if (link =~ /^https/).nil? && (link =~ /^http/).nil?
          error = ErrorUtil::ConfigFileInValid.new("Invalid link for [link] : #{link}")
          error_list.push(error)
        else
          newlink = link
        end
      end

      if !(xlsxpath.nil? || xlsxpath.length == 0)
        if !(Pathname.new xlsxpath).absolute?
          newxlsxpath = File.expand_path(xlsxpath, File.dirname(FileUtil.configfile_pathstr))
        else
          newxlsxpath = xlsxpath
        end
      else
        error = ErrorUtil::ConfigFileInValid.new('[xlsxpath] should not be empty or missing')
        error_list.push(error)
      end

      if platform.nil? || platform.length == 0
        error = ErrorUtil::ConfigFileInValid.new('[platform] should not be empty')
        error_list.push(error)
      else
        if Platform.init(platform).nil?
          error = ErrorUtil::ConfigFileInValid.new("[platform] can only be 'ios' or 'android' ")
          error_list.push(error)
        else
          newplatform = Platform.init(platform)
        end
      end

      if keystr.nil? || keystr.length == 0
        error = ErrorUtil::ConfigFileInValid.new('[keystr] should not be empty')
        error_list.push(error)
      else
        newkeystr = keystr
      end

      if langlist.nil?
        error = ErrorUtil::ConfigFileInValid.new('[langlist] should not be empty or missing')
        error_list.push(error)
      elsif !(langlist.is_a? Hash)
        error = ErrorUtil::ConfigFileInValid.new('[langlist] wrong format')
        error_list.push(error)
      else
        if langlist.length <= 0
          error = ErrorUtil::ConfigFileInValid.new('[langlist] should not be empty ')
          error_list.push(error)
        end
        langlist.each do |lang, arr|
          if arr.length != 2
            error = ErrorUtil::ConfigFileInValid.new('[langlist] wrong format')
            error_list.push(error)
          else
            path = arr[1]
            unless (Pathname.new path).absolute?
              path = File.expand_path(path, File.dirname(FileUtil.configfile_pathstr))
            end
            if newplatform != nil
              if Platform.is_valid_path(newplatform, path)
                newlanglist[lang] = {:xlsheader => arr[0], :path => path}
              else
                if newplatform == Platform::IOS
                  error = ErrorUtil::ConfigFileInValid.new("wrong locale file type: IOS should be .strings : #{path}")
                else
                  error = ErrorUtil::ConfigFileInValid.new("wrong locale file type: Android should be .xml : #{path}")
                end
                error_list.push(error)
              end
            end
          end
        end
      end

      Setting.link = newlink
      Setting.platform = newplatform
      Setting.keystr = newkeystr
      Setting.langlist = newlanglist
      Setting.xlsxpath = newxlsxpath

      return error_list
    end

  end
end