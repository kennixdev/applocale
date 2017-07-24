require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../../Util/file_util.rb', __FILE__)
require File.expand_path('../../Util/error_util.rb', __FILE__)
require File.expand_path('../../Util/config_util.rb', __FILE__)
require File.expand_path('../GoogleHepler/google_helper.rb', __FILE__)
require File.expand_path('../ParseXLSX/parse_xlsx', __FILE__)
require File.expand_path('../ParserStringFile/parse_localized_resource.rb', __FILE__)
require File.expand_path('../convert_to_localefile', __FILE__)
require 'open-uri'

module Applocale

  def self.create_config_file(proj_path = Dir.pwd, platformStr = nil)
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    if platformStr.nil?
      if Dir.glob("#{proj_apath}/**/*.xcodeproj").length > 0 || Dir.glob("#{proj_apath}/*.xcworkspace").length > 0
        platformsybom = Platform::IOS
      elsif Dir.glob("#{proj_apath}/**/*.gradle").length > 0
        platformsybom = Platform::ANDROID
      else
        Applocale::ErrorUtil::CommandError.new("Mssing [platform] : ios | android ").raise
      end
    else
      platformsybom = Platform.init(platform.strip)
    end
    if platformsybom.nil?
      ErrorUtil::CommandError.new("Invalid [platform] : ios | android ").raise
    else
      Applocale::Config::ConfigUtil.create_configfile_ifneed(platformsybom,proj_apath.to_s )
    end
  end

  def self.start_update(proj_path = Dir.pwd)
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    obj = Applocale::Config::ConfigUtil.new(proj_apath)
    setting = obj.load_configfile_to_setting
    if setting.link.to_s.length <= 0
      ErrorUtil::ConfigFileInValid.new('[link] is missing in config file ').raise
    end
    if Applocale::GoogleHelper.is_googlelink(setting.link)
      if setting.google_credentials_path.to_s.length <= 0
        setting.google_credentials_path = File.expand_path(FilePathUtil.default_google_credentials_filename, File.dirname(setting.configfile_pathstr))
      end
      googleobj = Applocale::GoogleHelper.new(setting.link, setting.google_credentials_path, setting.xlsxpath)
      googleobj.download
    else
      download = open(setting.link)
      IO.copy_stream(download, setting.xlsxpath)
    end
    Applocale.start_local_update(proj_path, setting)
  end

  def self.start_local_update(proj_path = Dir.pwd, asetting = nil)
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    setting = asetting
    if setting.nil?
      obj = Applocale::Config::ConfigUtil.new(proj_apath)
      setting = obj.load_configfile_to_setting
    end
    parse_xlsx = Applocale::ParseXLSX.new(setting.platform, setting.xlsxpath, setting.lang_path_list, setting.sheet_obj_list)
    ConvertToStrFile.convert(setting.platform, setting.lang_path_list,parse_xlsx.result, setting.rubycode)
  end

  def self.start_reverse(proj_path = Dir.pwd, is_skip)
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    obj = Applocale::Config::ConfigUtil.new(proj_apath)
    setting = obj.load_configfile_to_setting
    Applocale::ParseLocalizedResource.new(is_skip,setting.platform,setting.xlsxpath, setting.lang_path_list, setting.sheet_obj_list, setting.rubycode )
  end
#
# def self.eval_file(file)
#   instance_eval read(file), file
# end
  
  #
# def self.genxlsx_from_source_code(path, platformStr = nil)
  #
  # end

end

path = "/Users/kennix.chui/Documents/Development/iOS"
apath = "/Users/kennix.chui/Documents/Development/iOS/AppLocale/AppLocaleFile"

Applocale.start_reverse(path, true)
# def from_file file
#   new File.read(file), file
# end
# from_file(apath)



# Applocale.create_config_file(path)
# Applocale.start_local_update(path)
# Applocale.start_update(path)
# Applocale.create_config_file(path)