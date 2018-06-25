require File.expand_path('../platform.rb', __FILE__)
require File.expand_path('../lang.rb', __FILE__)
require 'pathname'

module Applocale
  class FilePathUtil
    DIRNAME_MAIN = 'AppLocale'
    DIRNAME_IOS = 'IOS'
    DIRNAME_ANDROID = 'Android'
    FILENAME_CONFIG = 'AppLocaleFile'
    FILENAME_XLSX = 'string.xlsx'
    GOOGLE_CREDENTIALS = 'google_credentials.yaml'
    EXPORT_FORMAT = :xlsx
    EXPORT_TO = 'resources'

    def self.get_proj_absoluat_path(proj_path)
      path = proj_path
      if !(Pathname.new proj_path).absolute?
        path = File.expand_path(proj_path,Dir.pwd)
      end
      return path
    end

    def self.default_google_credentials_filename
      return GOOGLE_CREDENTIALS
    end

    def self.default_config_filename
      return FILENAME_CONFIG
    end

    def self.default_mainfolder
      return DIRNAME_MAIN
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

    def self.default_export_format
      EXPORT_FORMAT
    end

    def self.default_export_to
      EXPORT_TO
    end

    def self.str_to_folderpathstr(str)
      pathstr = Pathname.new(str.strip)
      if File.directory?(pathstr)
        pathstr = File.join(self.configfile_pathstr, FilePathUtil.default_config_filename).to_s
      end
    end
  end
end

