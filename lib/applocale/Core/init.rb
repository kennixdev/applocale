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
require File.expand_path('../CompareStringFile/compare_string_file', __FILE__)
require File.expand_path('../CompareStringFile/compare_string_files', __FILE__)

require 'open-uri'

module Applocale

  def self.create_config_file( platformStr = nil, projpath = Dir.pwd, configFile = FilePathUtil.default_config_filename)
    configfile_name = configFile
    configfile_name = FilePathUtil.default_config_filename if configfile_name.nil?
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    if platformStr.nil?
      if Dir.glob("#{proj_apath}/**/*.xcodeproj").length > 0 || Dir.glob("#{proj_apath}/*.xcworkspace").length > 0
        platformsybom = Platform::IOS
      elsif Dir.glob("#{proj_apath}/**/*.gradle").length > 0
        platformsybom = Platform::ANDROID
      else
        Applocale::ErrorUtil::CommandError.new("Missing [platform] : ios | android | json").raise
      end
    else
      platformsybom = Platform.init(platformStr.strip)
    end
    if platformsybom.nil?
      ErrorUtil::CommandError.new("Invalid [platform] : ios | android | json").raise
    else
      Applocale::Config::ConfigUtil.create_configfile_ifneed(platformsybom,proj_apath.to_s, configfile_name )
    end
  end

  def self.start_update(projpath = Dir.pwd, configFile = FilePathUtil.default_config_filename)
    configfile_name = configFile
    configfile_name = FilePathUtil.default_config_filename if configfile_name.nil?
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    obj = Applocale::Config::ConfigUtil.new(proj_apath, configfile_name)
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
    Applocale.start_local_update(setting, proj_path, configfile_name)
  end

  def self.start_local_update(asetting = nil, projpath = Dir.pwd, configFile = FilePathUtil.default_config_filename.to_s)
    configfile_name = configFile
    configfile_name = FilePathUtil.default_config_filename if configfile_name.nil?
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    setting = asetting
    if setting.nil?
      obj = Applocale::Config::ConfigUtil.new(proj_apath, configfile_name)
      setting = obj.load_configfile_to_setting
    end
    case setting.export_format
    when 'csv'
      parser = Applocale::ParseCSV.new(setting)
    when 'xlsx'
      parser = Applocale::ParseXLSX.new(setting)
    end
    ConvertToStrFile.convert(setting, parser.result)
  end

  def self.start_reverse( is_skip, projpath = Dir.pwd, configFile = FilePathUtil.default_config_filename)
    configfile_name = configFile
    configfile_name = FilePathUtil.default_config_filename if configfile_name.nil?
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    obj = Applocale::Config::ConfigUtil.new(proj_apath, configfile_name)
    setting = obj.load_configfile_to_setting
    Applocale::ParseLocalizedResource.new(is_skip,setting.platform,setting.xlsxpath, setting.lang_path_list, setting.sheet_obj_list, setting.convert_file )
  end

  def self.findkey( key, projpath = Dir.pwd, configFile = FilePathUtil.default_config_filename)
    configfile_name = configFile
    configfile_name = FilePathUtil.default_config_filename if configfile_name.nil?
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    obj = Applocale::Config::ConfigUtil.new(proj_apath, configfile_name)
    report_folder = File.dirname(obj.configfile_pathstr)
    findobj = FindStrKey::FindValue.new(Applocale::Platform::IOS, proj_apath, report_folder, key)
    findobj.find
  end

  def self.compare(file1, file2)
    file1_path = Applocale::FilePathUtil.get_proj_absoluat_path(file1)
    file2_path = Applocale::FilePathUtil.get_proj_absoluat_path(file2)

    unless File.exist?(file1_path)
      ErrorUtil::FileNotExist.new.raise
    end
    unless File.exist?(file2_path)
      ErrorUtil::FileNotExist.new.raise
    end

    ext1 = File.extname(file1).strip.downcase[1..-1]
    ext2 = File.extname(file2).strip.downcase[1..-1]
    if ext1 != ext2
      ErrorUtil::FileMustSameExt.new.raise
    end

    if ext1 == 'strings'
      platformsybom = Platform::IOS
    elsif ext2 == 'xml'
      platformsybom = Platform::ANDROID
    end

    Applocale::CompareStringFile.new(platformsybom,file1_path,file2_path).compare
  end

  def self.compare_local(file1, file2, projpath = Dir.pwd, result_file)
    puts 'Reminder: run `update` for both files before `compare`'.yellow
    proj_path = projpath
    proj_path = Dir.pwd if projpath.nil?
    proj_apath = Applocale::FilePathUtil.get_proj_absoluat_path(proj_path)
    obj1 = Applocale::Config::ConfigUtil.new(proj_apath, file1)
    obj2 = Applocale::Config::ConfigUtil.new(proj_apath, file2)
    setting1 = obj1.load_configfile_to_setting(false)
    setting2 = obj2.load_configfile_to_setting(false)
    platform1 = setting1.platform
    platform2 = setting2.platform
    if platform1 != platform2
      ErrorUtil::FileMustSamePlatform.new.raise
    end
    if result_file.nil?
      ErrorUtil::MissingComparisonResultFilePath.new.raise
    end
    if File.extname(result_file).strip.downcase[1..-1].downcase != 'csv'
      ErrorUtil::NotSupportComparisonResultFileExtension.new.raise
    end
    result_file_path = File.join(proj_apath, FilePathUtil.default_mainfolder, result_file)
    Applocale::CompareStringFiles.new(platform1, file1, file2, setting1, setting2, result_file_path)
  end
end
