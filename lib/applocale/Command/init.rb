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
      desc "init [platform]", "Create Config File, platform: ios | android | json"
      option :path, :desc => "Project dir path"
      def init(platform = nil)
        Applocale.create_config_file(platform, options[:path])
      end

      desc "update", "Download xlsx and convert to localization string file"
      option :path, :desc => "Project dir path"
      def update()
        Applocale.start_update(options[:path])
      end

      desc "update_local", "Convert local xlsx file to localization string file"
      option :path, :desc => "Project dir path"
      def update_local()
        Applocale.start_local_update(nil,options[:path])
      end

      desc "reverse", "Convert localization string file to xlsx"
      option :skip, :desc => "Skip Error"
      option :path, :desc => "Project dir path"
      def reverse()
        is_skip = !options[:skip].nil?
        Applocale::start_reverse(is_skip, options[:path])
      end

      desc "version", "show the AppLocale verions"
      def version()
        puts Applocale::VERSION
      end

      # desc "google_logout", "logout google account"
      # def google_logout()
      #   GoogleHelper.reset_loginacc
      # end

      desc "findkey [key]", "findkey for ios and convert to xlsx"
      option :path, :desc => "Project dir path"
      def findkey(key)
        Applocale::findkey(key, options[:path])
      end
    end
  end
end

# Applocale.create_config_file('json')
Applocale.start_update(nil)
