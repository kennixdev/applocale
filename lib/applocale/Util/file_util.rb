require File.expand_path('../platform.rb', __FILE__)
require File.expand_path('../lang.rb', __FILE__)
require 'pathname'

module Applocale
  class FilePathUtil
    DIRNAME_MAIN = 'AppLocale'
    DIRNAME_IOS = 'IOS'
    DIRNAME_ANDROID = 'Android'
    FILENAME_CONFIG = 'AppLocaleFile.yaml'
    FILENAME_XLSX = 'string.xlsx'

    def self.default_filename_config
      return FILENAME_CONFIG
    end

    def self.default_mainfolder_pathstr
      pathstr = File.join(Dir.pwd, DIRNAME_MAIN)
      Dir.mkdir pathstr unless File.exist?(pathstr)
      return pathstr
    end

    def self.default_configfile_pathstr
      filename = self.default_filename_config
      pathstr = File.join(self.mainfolder_pathstr, filename)
      return pathstr
    end

    def self.default_localefile_relative_pathstr(platform, lang)
      if platform == Platform::IOS
        dirname = DIRNAME_IOS
      elsif platform == Platform::ANDROID
        dirname = DIRNAME_ANDROID
      end
      unless dirname.nil?
        filename = Locale.filename(platform, lang)
        return "#{dirname}/#{filename}"
      end
      return nil
    end

    def self.default_xlsx_relativepath_str
      filename = FILENAME_XLSX
      return filename
    end
  end
end

