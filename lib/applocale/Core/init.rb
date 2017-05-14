require File.expand_path('../setting.rb', __FILE__)
require File.expand_path('../GoogleHepler/google_helper.rb', __FILE__)
require File.expand_path('../ParseXLSX/parse_xlsx', __FILE__)
require File.expand_path('../convert_to_localefile', __FILE__)

module Applocale
  def self.start_update(is_localupdate, setting)
    unless is_localupdate
      google_file_id = GoogleHelper.is_googlelink(setting.link)
      unless google_file_id.nil?
        GoogleHelper.download_spreadsheet(google_file_id, setting.xlsxpath)
      end
    end

    parse_xlsx = ParseXLSX.new
    ConvertToStrFile.convert(parse_xlsx.result)
  end

  def self.start_reverse(is_skip)
    Applocale::ParseLocalizedResource.new(is_skip)
  end

end