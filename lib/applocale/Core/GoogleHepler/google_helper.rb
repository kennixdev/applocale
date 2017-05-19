require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'colorize'
require File.expand_path('../../../Util/file_util.rb', __FILE__)
require File.expand_path('../../../Util/error_util.rb', __FILE__)

module Applocale

  class GoogleHelper
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
    APPLICATION_NAME = 'AppLocale'
    CLIENT_SECRETS_PATH = 'client_secret.json'
    CREDENTIALS_PATH = File.join(Dir.home, '.applan_credentials',
                                 'drive-ruby-applocale.yaml')
    SCOPE = [Google::Apis::DriveV3::AUTH_DRIVE_METADATA_READONLY, Google::Apis::DriveV3::AUTH_DRIVE, Google::Apis::DriveV3::AUTH_DRIVE_FILE]

    def self.is_googlelink(link)
      if !link.nil? && link.length > 0
        if link.match(/https:\/\/docs.google.com\/spreadsheets\/d\/([^\/]*)/i)
          if $1.length > 0
            return $1
          end
        end
      end
    end

    def self.reset_loginacc
      if File.exist? CREDENTIALS_PATH
        File.delete(CREDENTIALS_PATH)
      end
      puts "Account Reseted!"
    end

    def self.download_spreadsheet(spreadsheet_Id, filename)
      puts "Start download from google, fileId: #{spreadsheet_Id} ...".green
      service = Google::Apis::DriveV3::DriveService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = self.authorize
      begin
        service.export_file(spreadsheet_Id,
                                      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                                      download_dest: filename)
        if File.exist? filename
          puts 'Download from google finished'.green
        else
          ErrorUtil::DownloadFromGoogleFail.new.raise
        end
      rescue Google::Apis::AuthorizationError => e
        self.failauth(spreadsheet_Id, filename)
      rescue Google::Apis::ClientError => e
        self.failauth(spreadsheet_Id, filename)
      rescue Google::Apis::ServerError => e
        self.failauth( spreadsheet_Id, filename)
      rescue
        ErrorUtil::DownloadFromGoogleFail.new.raise
      end
    end

    def self.failauth(spreadsheet_Id, filename)
      ErrorUtil::DownloadFromGoogleFail.new.to_warn
      self.askfor_relogin(true, spreadsheet_Id, filename)
    end

    private
    def self.askfor_relogin(is_firsttime, spreadsheet_Id, filename)
      unless is_firsttime
        puts "Invalid Command. Please input [Y/N]".red
      end
      puts "login again? [Y/N]".red
      code = STDIN.gets.chomp.downcase
      if code == 'y'
        self.reset_loginacc
        self.download_spreadsheet(spreadsheet_Id, filename)
      elsif code == 'n'
        exit(0)
      else
        self.askfor_relogin(false, spreadsheet_Id, filename)
      end
    end

    def self.authorize

      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
      client_id = Google::Auth::ClientId.from_file(File.expand_path(CLIENT_SECRETS_PATH, File.dirname(__FILE__)))
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(
          client_id, SCOPE, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(
            base_url: OOB_URI)
        puts '!!! Open the following URL in the browser and enter the '.red +
                 'resulting code after authorization:'.red
        puts url.blue.on_white
        code = STDIN.gets.chomp
        credentials = authorizer.get_and_store_credentials_from_code(
            user_id: user_id, code: code, base_url: OOB_URI)
      end
      credentials
    end

  end
end
