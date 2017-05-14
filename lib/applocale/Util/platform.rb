module Applocale

  module Platform
    IOS = :ios
    ANDROID = :Android

    def self.init(platform)
      if platform.upcase == 'IOS'
        return Platform::IOS
      elsif platform.upcase == 'ANDROID'
        return Platform::ANDROID
      end
      return nil
    end

    def self.is_valid_path(platform, path)
      newpath = path.to_s.strip
      extn = File.extname  newpath
      if platform == Platform::IOS
        if extn.downcase == '.strings'
          return true
        end
      elsif platform == Platform::ANDROID
        if extn.downcase == '.xml'
          return true
        end
      end
      return false
    end
  end

end
