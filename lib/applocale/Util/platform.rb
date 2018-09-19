module Applocale

  module Platform
    IOS = :ios
    ANDROID = :Android
    JSON = :json

    def self.init(platform)
      if platform.upcase == 'IOS'
        return Platform::IOS
      elsif platform.upcase == 'ANDROID'
        return Platform::ANDROID
      elsif platform.upcase == 'JSON'
        return Platform::JSON
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
      elsif platform == Platform::JSON
        return extn.downcase == '.json'
      end
      return false
    end
  end

end
