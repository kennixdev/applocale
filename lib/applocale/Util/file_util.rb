require File.expand_path('../platform.rb', __FILE__)
require File.expand_path('../lang.rb', __FILE__)
require 'pathname'

module Applocale
  class FileUtil
    @@dirname_main = "AppLocale"
    @@dirname_ios = "IOS"
    @@dirname_android = "Android"
    @@filename_config = "AppLocaleFile.yaml"
    @@filename_xlsx = "string.xlsx"

    def self.filename_config
      return @@filename_config
    end

    def self.mainFolderPathStr
      pathstr = File.join(Dir.pwd, @@dirname_main)
      Dir.mkdir pathstr unless File.exist?(pathstr)
      return pathstr
    end

    def self.configFilePathStr
      filename = @@filename_config
      pathstr = File.join(self.mainFolderPathStr, filename)
      return pathstr
    end

    def self.createConfigFileIfNeed(platform)
      pathstr = self.configFilePathStr
      self.createConfigFile(pathstr, platform) unless File.exist?(pathstr)
    end

    def self.defaultLocaleFileRelativePathStr(platform, lang)
      if platform == Platform::IOS
        dirname = @@dirname_ios
      elsif platform == Platform::ANDROID
        dirname = @@dirname_android
      end
      if !dirname.nil?
        dirpathstr = File.join(self.mainFolderPathStr, dirname)
        Dir.mkdir dirpathstr unless File.exist?(dirpathstr)
        filename = Locale.filename(platform, lang)
        filepathstr = File.join(dirpathstr, filename)
        filepath = Pathname.new(filepathstr)
        configfilepath = Pathname.new(File.dirname(self.configFilePathStr))
        return filepath.relative_path_from(configfilepath).to_s
      end
      return nil
    end

    def self.defaultXlsxRelativePathStr
      filename = @@filename_xlsx
      pathstr = File.join(self.mainFolderPathStr, filename)
      filepath = Pathname.new(pathstr)
      configfilepath = Pathname.new(File.dirname(self.configFilePathStr))
      return filepath.relative_path_from(configfilepath).to_s
    end
  end
end

