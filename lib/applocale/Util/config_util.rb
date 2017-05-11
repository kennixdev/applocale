require 'yaml'
require File.expand_path('../file_util.rb', __FILE__)
require File.expand_path('../error_util.rb', __FILE__)
require File.expand_path('../platform.rb', __FILE__)
require File.expand_path('../../Core/setting.rb', __FILE__)

require 'pathname'

module Applocale
  class ConfigUtil
    def self.createConfigFileIfNeed(platform)
      pathstr = FileUtil.configFilePathStr
      self.createConfigFile(platform, pathstr) unless File.exist?(pathstr)
    end

    def self.createConfigFile(platform, configfile_pathstr)
      src_pathstr = File.expand_path("../../#{FileUtil.filename_config}", __FILE__)

      File.open(src_pathstr, "r") do |form|
        File.open(configfile_pathstr, "w") do |to|
          form.each_line do |line|
            newline = line.gsub("\#{platform}", "#{platform.to_s}")
            newline = newline.gsub("\#{path_zh_TW}", FileUtil.defaultLocaleFileRelativePathStr(platform, Locale::ZH_TW))
            newline = newline.gsub("\#{path_zh_CN}", FileUtil.defaultLocaleFileRelativePathStr(platform, Locale::ZH_CN))
            newline = newline.gsub("\#{path_en_US}", FileUtil.defaultLocaleFileRelativePathStr(platform, Locale::EN_US))
            newline = newline.gsub("\#{xlsxpath}", FileUtil.defaultXlsxRelativePathStr())
            to.puts(newline)
          end

        end
      end
    end

    def self.loadAndValidateForXlsxToStringFile(is_local_update)
      config_yaml = self.load_config
      self.validateForXlsxToStringFile(config_yaml, is_local_update)
    end

    def self.loadAndValidateForStringFileToXlsx()
      config_yaml = self.load_config
      self.validateForStringFileToXlsx(config_yaml)
    end

    # private
    def self.load_config
      configfile_path = FileUtil.configFilePathStr
      unless File.exist?(configfile_path)
        ErrorUtil::MissingConfigFileError.new("Missing ConfigFile").raise
      end
      config_yaml = YAML.load_file configfile_path
      return config_yaml
    end

    def self.validateForXlsxToStringFile(config_yaml, is_local_update)
      error_list = self.validateCommon(config_yaml)
      if is_local_update
        if !File.exist? Setting.xlsxpath
          error = ErrorUtil::ConfigFileValidError.new("#{Setting.xlsxpath} do not exist")
          error_list.push(error)
        end
      else
        if Setting.link.nil?
          error = ErrorUtil::ConfigFileValidError.new("[link] should not be empty")
          error_list.push(error)
        end
      end
      ErrorUtil::ConfigFileValidError.raiseArr(error_list)
    end

    def self.validateForStringFileToXlsx(config_yaml)
      error_list = self.validateCommon(config_yaml)
      Setting.langlist.each do |lang, langinfo|
        if !File.exist? langinfo[:path]
          error = ErrorUtil::ConfigFileValidError.new("#{langinfo[:path]} do not exist")
          error_list.push(error)
        end
      end
      ErrorUtil::ConfigFileValidError.raiseArr(error_list)
    end

    def self.validateCommon(config_yaml)
      error_list = Array.new
      link = config_yaml["link"].to_s
      platform = config_yaml["platform"].to_s
      keystr = config_yaml["keystr"].to_s
      langlist = config_yaml["langlist"]
      xlsxpath = config_yaml["xlsxpath"].to_s

      newlink = nil
      newplatform = nil
      newkeystr = nil
      newlanglist = Hash.new
      newxlsxpath = nil

      if !(link.nil? || link.length == 0)
        if (link =~ /^https/).nil? && (link =~ /^http/).nil?
          error = ErrorUtil::ConfigFileValidError.new("Invalid link for [link] : #{link}")
          error_list.push(error)
        else
          newlink = link
        end
      end

      if !(xlsxpath.nil? || xlsxpath.length == 0)
        if !(Pathname.new xlsxpath).absolute?
          newxlsxpath = File.expand_path(xlsxpath, File.dirname(FileUtil.configFilePathStr))
        else
          newxlsxpath = xlsxpath
        end
      else
        error = ErrorUtil::ConfigFileValidError.new("[xlsxpath] should not be empty or missing")
        error_list.push(error)
      end

      if platform.nil? || platform.length == 0
        error = ErrorUtil::ConfigFileValidError.new("[platform] should not be empty")
        error_list.push(error)
      else
        if Platform.init(platform).nil?
          error = ErrorUtil::ConfigFileValidError.new("[platform] can only be 'ios' or 'android' ")
          error_list.push(error)
        else
          newplatform = Platform.init(platform)
        end
      end

      if keystr.nil? || keystr.length == 0
        error = ErrorUtil::ConfigFileValidError.new("[keystr] should not be empty")
        error_list.push(error)
      else
        newkeystr = keystr
      end

      if langlist.nil?
        error = ErrorUtil::ConfigFileValidError.new("[langlist] should not be empty or missing")
        error_list.push(error)
      elsif !(langlist.is_a? Hash)
        error = ErrorUtil::ConfigFileValidError.new("[langlist] wrong format")
        error_list.push(error)
      else
        if langlist.length <= 0
          error = ErrorUtil::ConfigFileValidError.new("[langlist] should not be empty ")
          error_list.push(error)
        end
        langlist.each do |lang, arr|
          if arr.length != 2
            error = ErrorUtil::ConfigFileValidError.new("[langlist] wrong format")
            error_list.push(error)
          else
            path = arr[1]
            if !(Pathname.new path).absolute?
              path = File.expand_path(path, File.dirname(FileUtil.configFilePathStr))
            end
            newlanglist[lang] = {:xlsheader => arr[0], :path => path}
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