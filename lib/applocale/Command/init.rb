require File.expand_path('../../Util/file_util.rb', __FILE__)
require File.expand_path('../../Util/config_util.rb', __FILE__)
require File.expand_path('../../Util/error_util.rb', __FILE__)
require File.expand_path('../../Core/setting.rb', __FILE__)
require File.expand_path('../../Core/init.rb', __FILE__)
require File.expand_path('../../Core/ParserStringFile/parse_localized_resource.rb', __FILE__)
require File.expand_path('../../version', __FILE__)
require File.expand_path('../../Core/GoogleHepler/google_helper', __FILE__)

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
      option :path, :desc => "Project dir path"
      def update()
        Applocale.start_update(options[:path])
      end

      desc "update_local", "Convert local xlsx file to localization string filee"
      option :path, :desc => "Project dir path"
      def update_local()
        Applocale.start_local_update(options[:path], nil)
      end

      desc "reverse", "Convert localization string file to xlsx"
      option :skip, :desc => "Skip Error"
      def reverse()
        is_skip = !options[:skip].nil?
        Applocale::start_reverse(is_skip)
      end

      desc "version", "show the AppLocale verions"
      def version()
        puts Applocale::VERSION
      end

      desc "google_logout", "logout google account"
      def google_logout()
        GoogleHelper.reset_loginacc
      end

      desc "findkey", "findkey for ios and convert to xlsx"
      option :key, :desc => "The function name for localization"
      def findkey()
        # is_skip = !options[:skip].nil?
        # ConfigUtil.load_and_validate_localefile_to_xlsx()
        # Setting.printlog
        # Applocale::start_reverse(is_skip)
      end
    end
  end
end
