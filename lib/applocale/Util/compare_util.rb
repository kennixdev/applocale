module Applocale
  module Config
    class LangPathComparison
      attr_accessor :platform, :lang, :filepath1, :filepath2

      def initialize(platform, lang, filepath1, filepath2)
        self.platform = platform
        self.lang = lang
        self.filepath1 = filepath1
        self.filepath2 = filepath2
      end

      def self.init(platform, lang, filepath1, filepath2)
        LangPathComparison.new(platform, lang, filepath1, filepath2)
      end
    end

    class LangPathComparisonResult < LangPathComparison
      attr_accessor :platform, :lang, :filepath1, :filepath2, :warning, :not_same, :duplicate_key, :mismatch, :missing_in_1, :missing_in_2

      def initialize(langpath_comparison, warning = nil)
        super(langpath_comparison.platform, langpath_comparison.lang, langpath_comparison.filepath1, langpath_comparison.filepath2)
        self.warning = warning
      end

      def self.init(platform, lang, filepath1, filepath2, not_same, duplicate_key, mismatch, missing_in_1, missing_in_2)
        langpath_comparison = LangPathComparison.init(platform, lang, filepath1, filepath2)
        result = LangPathComparisonResult.new(langpath_comparison)
        result.not_same = not_same
        result.duplicate_key = duplicate_key
        result.mismatch = mismatch
        result.missing_in_1 = missing_in_1
        result.missing_in_2 = missing_in_2
        result
      end
    end
  end
end