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
    SCOPE = [Google::Apis::DriveV3::AUTH_DRIVE_METADATA_READONLY, Google::Apis::DriveV3::AUTH_DRIVE, Google::Apis::DriveV3::AUTH_DRIVE_FILE]

    attr_accessor :download_link, :credential_path, :xlsx_path,:spreadsheet_id

    def initialize(link, credential_path, xlsx_path)
      self.download_link = link.to_s.strip
      self.credential_path = credential_path.to_s.strip
      self.xlsx_path = xlsx_path.to_s.strip
      self.spreadsheet_id = GoogleHelper.get_spreadsheet_id(link)

      if self.download_link.length <= 0
        ErrorUtil::ConfigFileInValid.new('[link] is missing in config file ').raise
      end
      if self.credential_path.length <= 0
        ErrorUtil::ConfigFileInValid.new('[credential_path] is missing in config file ').raise
      end
      if self.xlsx_path.length <= 0
        ErrorUtil::ConfigFileInValid.new('[xlsx_path] is missing in config file ').raise
      end
    end

    private
    def removeOldExcel
      if File.exist? self.xlsx_path
        FileUtils.rm(self.xlsx_path)
      end
    end

    public
    def download
      removeOldExcel
      service = Google::Apis::DriveV3::DriveService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = authorize
      begin
        service.export_file(self.spreadsheet_id,
                            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                            download_dest: self.xlsx_path)
        if File.exist? self.xlsx_path
          puts 'Download from google finished'.green
        else
          ErrorUtil::DownloadFromGoogleFail.new.raise
        end
      rescue Google::Apis::AuthorizationError => e
        failauth
      rescue Google::Apis::ClientError => e
        failauth
      rescue Google::Apis::ServerError => e
        failauth
      rescue
        ErrorUtil::DownloadFromGoogleFail.new.raise
      end
    end

    private
    def failauth
      ErrorUtil::DownloadFromGoogleFail.new.to_warn
      askfor_relogin(true)
    end

    private
    def askfor_relogin(is_firsttime)
      unless is_firsttime
        puts "Invalid Command. Please input [Y/N]".red
      end
      puts "login again? [Y/N]".red
      code = STDIN.gets.chomp.downcase
      if code == 'y'
        reset_loginacc
        self.download
      elsif code == 'n'
        exit(0)
      else
        askfor_relogin(false)
      end
    end

    private
    def authorize
      FileUtils.mkdir_p(File.dirname(self.credential_path))
      client_id = Google::Auth::ClientId.from_file(File.expand_path(CLIENT_SECRETS_PATH, File.dirname(__FILE__)))
      token_store = Google::Auth::Stores::FileTokenStore.new(file: self.credential_path)
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

    private
    def reset_loginacc
      if File.exist? self.credential_path
        File.delete(self.credential_path)
      end
      puts "Account Reseted!"
    end

    public
    def self.is_googlelink(link)
      if !link.nil? && link.length > 0
        if link.match(/https:\/\/docs.google.com\/spreadsheets\/d\/([^\/]*)/i)
          if $1.length > 0
            return true
          end
        end
      end
      return false
    end

    public
    def self.get_spreadsheet_id(link)
      if !link.nil? && link.length > 0
        if link.match(/https:\/\/docs.google.com\/spreadsheets\/d\/([^\/]*)/i)
          if $1.strip.length > 0
            return $1.strip
          end
        end
      end
      ErrorUtil::DownloadFromGoogleFail.new.raise
    end

  end
end
