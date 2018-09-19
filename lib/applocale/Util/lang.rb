
module Applocale
  module Locale
    ZH_TW = :zh_TW
    ZH_CN = :zh_CN
    EN_US = :en_US
    FILENAME_IOS = {Locale::ZH_CN => 'zh_CN.strings', Locale::ZH_TW => 'zh_TW.strings', Locale::EN_US => 'en_US.strings'}
    FILENAME_ANDROID = {Locale::ZH_CN => 'values-zh-rCN', Locale::ZH_TW => 'values-zh-rTW', Locale::EN_US => 'values'}

    def self.filename(devicemodel, locale)
      if devicemodel == Platform::IOS
        return !FILENAME_IOS[locale].nil? ? FILENAME_IOS[locale] : "#{locale}.strings"
      elsif devicemodel == Platform::ANDROID
        return File.join(FILENAME_ANDROID[locale],'strings.xml')
      elsif devicemodel == Platform::JSON
        return "#{locale}.json"
      end
      return nil
    end

    def self.init(langstring)
      if langstring.upcase == 'ZH_TW'
        return Locale::ZH_TW
      elsif langstring.upcase == 'ZH_CN'
        return Locale::ZH_CN
      elsif langstring.upcase == 'EN_US'
        return Locale::EN_US
      end
      return langstring
    end
  end
end
