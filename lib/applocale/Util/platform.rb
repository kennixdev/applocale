module Applocale

  module Platform
    IOS = :ios
    ANDROID = :Android

    def self.init(platform)
      if platform.upcase == "IOS"
        return Platform::IOS
      elsif platform.upcase == "ANDROID"
        return Platform::ANDROID
      end
      return nil
    end
  end

end
