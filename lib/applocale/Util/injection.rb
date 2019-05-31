

module Applocale
  class Injection
    def self.load(rubycode)
      obj = Applocale::Injection.new()
      obj.load(rubycode)
      return obj
    end

    def load(rubycode)
      if !rubycode.nil?
        eval rubycode
      end
    end

    public
    def has_convent_to_locale
      return defined?(convent_to_locale) == 'method'
    end

    public
    def load_convent_to_locale(lang, key, value)
      return convent_to_locale(lang, key, value)
    end

    public
    def has_before_convent_to_locale
      return defined?(before_convent_to_locale) == 'method'
    end

    public
    def load_before_convent_to_locale(lang, key, value)
      return before_convent_to_locale(lang, key, value)
    end

    public
    def has_after_convent_to_locale
      return defined?(after_convent_to_locale) == 'method'
    end

    public
    def load_after_convent_to_locale(lang, key, value)
      return after_convent_to_locale(lang, key, value)
    end

    #
    public
    def has_parse_from_locale
      return defined?(parse_from_locale) == 'method'
    end

    public
    def load_parse_from_locale(lang, key, value)
      return parse_from_locale(lang, key, value)
    end

    public
    def has_before_parse_from_locale
      return defined?(before_parse_from_locale) == 'method'
    end

    public
    def load_before_parse_from_locale(lang, key, value)
      return before_parse_from_locale(lang, key, value)
    end

    public
    def has_after_parse_from_locale
      return defined?(after_parse_from_locale) == 'method'
    end

    public
    def load_after_parse_from_locale(lang, key, value)
      return after_parse_from_locale(lang, key, value)
    end

    public
    def has_is_skip_by_key
      return defined?(is_skip_by_key) == 'method'
    end

    public
    def load_is_skip_by_key(sheetname, key)
      return is_skip_by_key(sheetname, key)
    end

  end
end
