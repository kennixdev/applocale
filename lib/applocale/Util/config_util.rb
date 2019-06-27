require 'yaml'
require File.expand_path('../file_util.rb', __FILE__)
require File.expand_path('../error_util.rb', __FILE__)
require File.expand_path('../platform.rb', __FILE__)
require File.expand_path('../../Core/setting.rb', __FILE__)
require File.expand_path('../convert_util.rb', __FILE__)

require 'pathname'

module Applocale
  module Config
    class ConfigUtil
      attr_accessor :configfile_pathstr, :configFile

      def initialize(projectdir_path, config_filename)
        projpath = Pathname.new(projectdir_path.strip)
        if File.directory?(projpath)
          self.configFile = config_filename
          self.configfile_pathstr = File.join(projpath, FilePathUtil.default_mainfolder, config_filename)
          FileUtils.mkdir_p(File.dirname(self.configfile_pathstr))
        else
          ErrorUtil::ConfigFileInValid.new('Project Path is invalid.').raise
        end
      end

      public
      def create_configfile(platform)
        if !File.exist?(self.configfile_pathstr)
          src_pathstr = File.expand_path("../../#{self.configFile}", __FILE__)
          File.open(src_pathstr, 'r') do |form|
            File.open(configfile_pathstr, 'w') do |to|
              form.each_line do |line|
                newline = line.gsub("\#{platform}", "#{platform.to_s}")
                newline = newline.gsub("\#{path_zh_TW}", FilePathUtil.default_localefile_relative_pathstr(platform, Locale::ZH_TW))
                newline = newline.gsub("\#{path_zh_CN}", FilePathUtil.default_localefile_relative_pathstr(platform, Locale::ZH_CN))
                newline = newline.gsub("\#{path_en_US}", FilePathUtil.default_localefile_relative_pathstr(platform, Locale::EN_US))
                newline = newline.gsub("\#{resource_folder}", FilePathUtil.default_export_to)
                newline = newline.gsub("\#{xlsxpath}", FilePathUtil.default_xlsx_relativepath_str)
                newline = newline.gsub("\#{google_credentials_path}", FilePathUtil.default_google_credentials_filename)
                newline = newline.gsub("\#{export_format}", FilePathUtil.default_export_format.to_s)
                to.puts(newline)
              end
            end
          end
          converfile = "convert.rb"
          src_pathstr = File.expand_path("../../#{converfile}", __FILE__)
          FileUtils.cp(src_pathstr, File.expand_path("convert.rb",File.dirname(self.configfile_pathstr)))
        end
      end

      public
      def self.create_configfile_ifneed(platform, projectdir_path, config_filename)
        config = ConfigUtil.new(projectdir_path, config_filename)
        config.create_configfile(platform)
      end

      private
      def load_configfile
        unless File.exist?(self.configfile_pathstr)
          ErrorUtil::MissingConfigFile.new.raise
        end
        begin
          yaml = ""
          File.open(self.configfile_pathstr).each do |line|
            reg = /\w*\s*:\s*"?.*"?/
            if line.match reg
              yaml += line
            end
          end
          config_yaml = YAML.load( yaml)
        rescue
          ErrorUtil::ConfigFileInValid.new('ConfigFile format is invalid.')
        end
        return config_yaml
      end

      public
      def load_configfile_to_setting
        error_list = Array.new
        config_yaml = load_configfile
        link = config_yaml['link'].to_s.strip
        platform = config_yaml['platform'].to_s.strip
        xlsxpath = config_yaml['xlsxpath'].to_s.strip
        google_credentials_path = config_yaml['google_credentials_path'].to_s.strip
        langlist = config_yaml['langlist']
        sheetname = config_yaml['sheetname']
        export_format = config_yaml['export_format']
        resource_folder = config_yaml['resource_folder']
        export_to = config_yaml['export_to']
        isSkipEmptyKey = config_yaml['isSkipEmptyKey']
        configFileFolder = File.dirname(self.configfile_pathstr)
        setting = Applocale::Config::Setting.new(self.configfile_pathstr)
        setting.convert_file = Applocale::ConvertFile.new(config_yaml['convertFile'],configFileFolder)

        unless link.nil? || link.length == 0
          if (link =~ /^https/).nil? && (link =~ /^http/).nil?
            error = ErrorUtil::ConfigFileInValid.new("Invalid link for [link] : #{link}")
            error_list.push(error)
          else
            setting.link = link
          end
        end

        if platform.nil? || platform.length == 0
          error = ErrorUtil::ConfigFileInValid.new('[platform] should not be empty')
          error_list.push(error)
        else
          if Platform.init(platform).nil?
            error = ErrorUtil::ConfigFileInValid.new("[platform] can only be 'ios', 'android' or 'json'.")
            error_list.push(error)
          else
            setting.platform = Platform.init(platform)
          end
        end

        export_format = 'xlsx' if export_format.nil?
        case export_format
        when 'csv', 'xlsx'
          setting.export_format = export_format
        else
          error = ErrorUtil::ConfigFileInValid.new("[export_format] for item can only be 'csv' or 'xlsx' ")
          error_list.push(error)
        end

        if resource_folder.nil? || resource_folder.length == 0
          setting.export_to = File.expand_path(FilePathUtil.default_export_to,configFileFolder)
        else
          setting.export_to = File.expand_path(resource_folder,configFileFolder)
        end

        if !(xlsxpath.nil? || xlsxpath.length == 0)
          if !(Pathname.new xlsxpath).absolute?
            setting.xlsxpath = File.expand_path(xlsxpath, setting.export_to)
          else
            setting.xlsxpath = xlsxpath
          end
        else
          error = ErrorUtil::ConfigFileInValid.new('[xlsxpath] should not be empty or missing')
          error_list.push(error)
        end

        if !(google_credentials_path.nil? || google_credentials_path.length == 0)
          if !(Pathname.new google_credentials_path).absolute?
            setting.google_credentials_path = File.expand_path(google_credentials_path, File.dirname(self.configfile_pathstr))
          else
            setting.google_credentials_path = google_credentials_path
          end
        end

        if langlist.nil?
          error = ErrorUtil::ConfigFileInValid.new('[langlist] should not be empty ')
          error_list.push(error)
        elsif !(langlist.is_a? Hash)
          error = ErrorUtil::ConfigFileInValid.new('[langlist] wrong format')
          error_list.push(error)
        elsif langlist.length <= 0
          error = ErrorUtil::ConfigFileInValid.new('[langlist] should not be empty ')
          error_list.push(error)
        else
          langlist.each do |lang, filepath|
            path = filepath.strip
            if path.length <= 0
              error = ErrorUtil::ConfigFileInValid.new("[#{lang}] in [langlist]  should not be empty ")
              error_list.push(error)
            else
              if !(Pathname.new path).absolute?
                path = File.expand_path(path,File.dirname(self.configfile_pathstr))
              end
              obj = LangPath.new(lang.to_s, path)
              setting.lang_path_list.push(obj)
            end
          end
        end

        if sheetname.nil?
          error = ErrorUtil::ConfigFileInValid.new('[sheetname] should not be empty ')
          error_list.push(error)
        elsif !(sheetname.is_a? Hash)
          error = ErrorUtil::ConfigFileInValid.new('[sheetname] wrong format, should be dict')
          error_list.push(error)
        elsif sheetname.length <= 0
          error = ErrorUtil::ConfigFileInValid.new('[sheetname] should not be empty ')
          error_list.push(error)
        else
          sheetname.each do |sheetname, infos|
            if !(infos.is_a? Hash)
              error = ErrorUtil::ConfigFileInValid.new("[sheetname] for item [#{sheetname}] is wrong format ")
              error_list.push(error)
            else
              lang_header_key_dict = {}
              langarr = setting.lang_path_list.map { |langpath| langpath.lang }
              langarr.each do |lang|
                info_lang = infos[lang].to_s.strip
                if info_lang.length <= 0
                  error = ErrorUtil::ConfigFileInValid.new("[sheetname] for item [#{sheetname}]: missing lang [#{lang}] ")
                  error_list.push(error)
                else
                  lang_header_key_dict[lang] = info_lang
                end
              end
              info_row = infos['row'].to_s.strip
              info_key = infos['key'].to_s.strip
              info_key_str = infos['key_str'].to_s.strip
              if info_row.length > 0 && info_key.length > 0
                obj = SheetInfoByRow.new(info_row.to_i, info_key, lang_header_key_dict)
                sheet = Sheet.new(sheetname,obj)
                setting.sheet_obj_list.push(sheet)
              elsif info_key_str.length > 0
                obj = SheetInfoByHeader.new(info_key_str, lang_header_key_dict)
                sheet = Sheet.new(sheetname,obj)
                setting.sheet_obj_list.push(sheet)
              else
                error = ErrorUtil::ConfigFileInValid.new("[sheetname] for item [#{sheetname}] is wrong format ")
                error_list.push(error)
              end
            end
          end
        end

        if isSkipEmptyKey.nil?
          setting.is_skip_empty_key = true
        elsif isSkipEmptyKey.to_s.downcase == "true" || isSkipEmptyKey.to_s.downcase == "false"
          setting.is_skip_empty_key = isSkipEmptyKey
        else
          error = ErrorUtil::ConfigFileInValid.new("[isSkipEmptyKey] must be boolean ")
          error_list.push(error)
        end
        setting.printlog
        ErrorUtil::ConfigFileInValid.raiseArr(error_list)
        return setting
      end
    end
  end
end

