
require File.expand_path('../../../Util/platform.rb', __FILE__)
require File.expand_path('../find_str_key_ios', __FILE__)
require File.expand_path('../find_str_key_result', __FILE__)

module FindStrKey
  class FindStrKeyObj
    attr_accessor :value, :file, :line
    def initialize(value, file, line)
      self.value = value
      self.file = file
      self.line = line
    end
  end
end

module FindStrKey
  class FindValue
    attr_accessor :platform, :proj_path, :report_folder, :key
    def initialize(platform, proj_path, report_folder, key)
      self.platform = platform
      self.proj_path = proj_path
      self.report_folder = report_folder
      self.key = key
    end


    def find()
      if platform == Applocale::Platform::IOS
        findobj = FindStrKey::FindValueIOS.new(self.proj_path, self.key)
        purekey_result_ordered, result_ordered = findobj.find
        gen = FindStrKey::GenReport.new(self.proj_path, self.report_folder,purekey_result_ordered, result_ordered)
        gen.gen_xlsx
        gen.gen_txt
      end
    end

  end
end

