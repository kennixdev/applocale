require File.expand_path('../platform.rb', __FILE__)
require File.expand_path('../lang.rb', __FILE__)
require 'pathname'

module Applocale
  class FileUtil
    DIRNAME_MAIN = 'AppLocale'
    DIRNAME_IOS = 'IOS'
    DIRNAME_ANDROID = 'Android'
    FILENAME_CONFIG = 'AppLocaleFile.yaml'
    FILENAME_XLSX = 'string.xlsx'

    def self.filename_config
      return FILENAME_CONFIG
    end

    def self.mainfolder_pathstr
      pathstr = File.join(Dir.pwd, DIRNAME_MAIN)
      Dir.mkdir pathstr unless File.exist?(pathstr)
      return pathstr
    end

    def self.configfile_pathstr
      filename = FILENAME_CONFIG
      pathstr = File.join(self.mainfolder_pathstr, filename)
      return pathstr
    end
    #
    # def self.create_configfile_ifneed(platform)
    #   pathstr = self.configfile_pathstr
    #   ConfigUtil.create_configfile(platform, pathstr) unless File.exist?(pathstr)
    # end

    def self.get_default_localefile_relative_pathstr(platform, lang)
      if platform == Platform::IOS
        dirname = DIRNAME_IOS
      elsif platform == Platform::ANDROID
        dirname = DIRNAME_ANDROID
      end
      unless dirname.nil?
        dirpathstr = File.join(self.mainfolder_pathstr, dirname)
        Dir.mkdir dirpathstr unless File.exist?(dirpathstr)
        filename = Locale.filename(platform, lang)
        filepathstr = File.join(dirpathstr, filename)
        filepath = Pathname.new(filepathstr)
        configfilepath = Pathname.new(File.dirname(self.configfile_pathstr))
        return filepath.relative_path_from(configfilepath).to_s
      end
      return nil
    end

    def self.get_default_xlsx_relativepath_str
      filename = FILENAME_XLSX
      pathstr = File.join(self.mainfolder_pathstr, filename)
      filepath = Pathname.new(pathstr)
      configfilepath = Pathname.new(File.dirname(self.configfile_pathstr))
      return filepath.relative_path_from(configfilepath).to_s
    end
  end
end

