require File.expand_path('../../Util/file_util.rb', __FILE__)
require File.expand_path('../../Util/config_util.rb', __FILE__)
require File.expand_path('../../Util/error_util.rb', __FILE__)
require File.expand_path('../../Core/setting.rb', __FILE__)
require File.expand_path('../../Core/init.rb', __FILE__)
require File.expand_path('../../Core/ParserStringFile/parse_localized_resource.rb', __FILE__)
require File.expand_path('../../version', __FILE__)

require 'thor'

module Applocale
  class Command
    class Init < Thor
      desc "init [platform]", "Create Config File, platform: ios | android"

      def init(platform = nil)
        if platform.nil?
          if Dir["*.xcodeproj"].length > 0
            platformsybom = Platform::IOS
          elsif Dir[".gradle"].length > 0
            platformsybom = Platform::ANDROID
          else
            self.class.help(shell)
            Applocale::ErrorUtil::CommandError.new("Mssing [platform] : ios | android ").raise
          end
        else
          platformsybom = Platform.init(platform)
        end

        if platformsybom.nil?
          self.class.help(shell)
          ErrorUtil::CommandError.new("Invalid [platform] : ios | android ").raise
        else
          ConfigUtil.create_configfile_ifneed(platformsybom)
        end
      end

      desc "update", "Download xlsx and convert to localization string file"
      option :local, :desc => "Convert local xlsx file to localization string file"
      def update()
        is_local = !options[:local].nil?
        ConfigUtil.load_and_validate_xlsx_to_localefile(is_local)
        Setting.printlog
        Applocale.start_update(is_local, Applocale::Setting)
      end

      desc "reverse", "Convert localization string file to xlsx"
      option :skip, :desc => "Skip Error"
      def reverse()
        is_skip = !options[:skip].nil?
        ConfigUtil.load_and_validate_localefile_to_xlsx()
        Setting.printlog
        Applocale::start_reverse(is_skip)
      end

      desc "version", "show the AppLocale verions"
      def version()
        puts Applocale::VERSION
      end

    end
  end
end
