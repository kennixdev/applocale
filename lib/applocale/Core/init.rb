require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../google_helper.rb', __FILE__)
require File.expand_path('../parse_xlsx', __FILE__)
require File.expand_path('../convert_to_str_file', __FILE__)

module Applocale
  def self.start(is_localupdate, setting)
    if !is_localupdate
      google_file_id = GoogleHelper.isGoogleLink(setting.link)
      if !google_file_id.nil?
        GoogleHelper.downloadSpreadSheet(google_file_id,setting.xlsxpath)
      end
    end

    parseXlsx = ParseXLSX.new()
    ConvertToStrFile.convert(parseXlsx.result)
  end

end
