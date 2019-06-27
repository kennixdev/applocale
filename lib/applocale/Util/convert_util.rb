require File.expand_path('../error_util.rb', __FILE__)

module Applocale
  class ConvertFile


    attr_accessor :filepath

    @convert
    @filepath


    def initialize(convert_file, dir)
      unless convert_file.nil?
        if convert_file.to_s.strip.length > 0
          convertFilePath = File.expand_path(convert_file, dir)
          if File.exist?(convertFilePath)
            require convertFilePath
            @convert = Convert.new()
            @filepath = convertFilePath.to_s
            return
          else
            ErrorUtil::ConfigFileInValid.new('convert file not exist ').raise
          end
        end
      end
      @convert = Object.new()
    end

    public
    def has_convent_to_locale
      return defined?(@convert.convent_to_locale) == 'method'
    end

    public
    def load_convent_to_locale(lang, key, before_convert_value, after_convert_value)
      return @convert.convent_to_locale(lang, key, before_convert_value, after_convert_value)
    end

    public
    def has_parse_from_locale
      return defined?(@convert.parse_from_locale) == 'method'
    end

    public
    def load_parse_from_locale(lang, key, before_convert_value, after_convert_value)
      return @convert.parse_from_locale(lang, key, before_convert_value, after_convert_value)
    end

    public
    def has_is_skip_by_key
      return defined?(@convert.is_skip_by_key) == 'method'
    end

    public
    def load_is_skip_by_key(sheetname, key)
      return @convert.is_skip_by_key(sheetname, key)
    end

    public
    def has_parse_from_excel_or_csv
      return defined?(@convert.parse_from_excel_or_csv) == 'method'
    end

    public
    def load_parse_from_excel_or_csv(sheetname, key, before_convert_value, after_convert_value)
      return @convert.parse_from_excel_or_csv(sheetname, key, before_convert_value, after_convert_value)
    end

    public
    def has_append_other
      return defined?(@convert.append_other) == 'method'
    end

    public
    def load_append_other(lang, target)
      return @convert.append_other(lang, target)
    end

  end
end