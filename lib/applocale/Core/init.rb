require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../../Util/file_util.rb', __FILE__)
require File.expand_path('../../Util/error_util.rb', __FILE__)
require File.expand_path('../../Util/config_util.rb', __FILE__)
require File.expand_path('../GoogleHepler/google_helper.rb', __FILE__)
require File.expand_path('../ParseXLSX/parse_xlsx', __FILE__)
require File.expand_path('../ParseCSV/parse_csv', __FILE__)
require File.expand_path('../ParserStringFile/parse_localized_resource.rb', __FILE__)
require File.expand_path('../convert_to_localefile', __FILE__)
require File.expand_path('../FindStrKey/find_str_key', __FILE__)

require 'open-uri'

module Applocale

  def self.create_config_file( platformStr = nil, projpath = Dir.pwd)
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
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
      platformsybom = Platform.init(platformStr.strip)
    end
    if platformsybom.nil?
      ErrorUtil::CommandError.new("Invalid [platform] : ios | android ").raise
    else
      Applocale::Config::ConfigUtil.create_configfile_ifneed(platformsybom,proj_apath.to_s )
    end
  end

  def self.start_update(projpath = Dir.pwd)
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
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
      googleobj.download(setting.sheet_obj_list, export_format: setting.export_format, export_to: setting.export_to)
    else
      download = open(setting.link)
      IO.copy_stream(download, setting.xlsxpath)
    end
    Applocale.start_local_update(setting, proj_path)
  end

  def self.start_local_update(asetting = nil, projpath = Dir.pwd)
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    setting = asetting
    if setting.nil?
      obj = Applocale::Config::ConfigUtil.new(proj_apath)
      setting = obj.load_configfile_to_setting
    end
    case setting.export_format
    when :csv
      parser = Applocale::ParseCSV.new(setting.platform, setting.export_to, setting.lang_path_list, setting.sheet_obj_list)
    when :xlsx
      parser = Applocale::ParseXLSX.new(setting.platform, setting.xlsxpath, setting.lang_path_list, setting.sheet_obj_list)
    end
    ConvertToStrFile.convert(setting.platform, setting.lang_path_list,parser.result, setting.rubycode)
  end

  def self.start_reverse( is_skip, projpath = Dir.pwd)
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    obj = Applocale::Config::ConfigUtil.new(proj_apath)
    setting = obj.load_configfile_to_setting
    Applocale::ParseLocalizedResource.new(is_skip,setting.platform,setting.xlsxpath, setting.lang_path_list, setting.sheet_obj_list, setting.rubycode )
  end

  def self.findkey( key, projpath = Dir.pwd)
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    obj = Applocale::Config::ConfigUtil.new(proj_apath)
    report_folder = File.dirname(obj.configfile_pathstr)
    findobj = FindStrKey::FindValue.new(Applocale::Platform::IOS, proj_apath, report_folder, key)
    findobj.find
  end
end
