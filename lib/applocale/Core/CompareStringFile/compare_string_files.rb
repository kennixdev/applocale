require 'parallel'
require 'csv'
require File.expand_path('../../../Util/platform.rb', __FILE__)
require File.expand_path('../../../Util/compare_util.rb', __FILE__)
require File.expand_path('../compare_string_file.rb', __FILE__)

module Applocale
  class CompareStringFiles
    attr_reader :platform, :applocale_file1, :applocale_file2, :setting1, :setting2, :langpath_comparison_list, :result_file
    def compare_all
      results = @langpath_comparison_list.map do |langpath_comparison|
        lang = langpath_comparison.lang
        file1 = langpath_comparison.filepath1
        file2 = langpath_comparison.filepath2
        if file1.nil? or file2.nil?
          Applocale::Config::LangPathComparisonResult.new(langpath_comparison, "Warning: [#{lang}] missing files for comparison!!!!!")
        else
          Applocale::CompareStringFile.compare(langpath_comparison)
        end
      end
      results.each {| result |
        unless result.warning.nil?
          puts result.warning.yellow
        end
      }
      write_result_to_csv(results)
      puts "Comparison Finished, output: #{result_file} !!!".green
    end

    def initialize(platform, applocale_file1, applocale_file2, setting1, setting2, result_file)
      @platform = platform
      @applocale_file1 = applocale_file1
      @applocale_file2 = applocale_file2
      @setting1 = setting1
      @setting2 = setting2
      @result_file = result_file
      @langpath_comparison_list = @setting1.lang_path_list.map do |lang_path_obj|
        file1 = lang_path_obj.filepath
        file2 = @setting2.lang_path_list.detect { |e| e.lang == lang_path_obj.lang }&.filepath
        Applocale::Config::LangPathComparison.new(platform, lang_path_obj.lang, file1,  file2)
      end
      compare_all
    end

    def write_result_to_csv(results)
      filtered_results = results.select do | result |
        result.warning.nil?
      end
      columns = filtered_results
                  .map { |result| result.lang }
                  .flat_map do | lang |
        ["notSame", "duplicateKey", "mismatch", "missingKeyIn1st", "missingkeyIn2nd"].map { |column| "#{lang}: #{column}" }
      end
      values =  filtered_results.flat_map { |result|
        [result.not_same,
        result.duplicate_key,
        result.mismatch,
        result.missing_in_1,
        result.missing_in_2]
      }
      values_max_length = values.max { |a,b| a.length <=> b.length }.length
      _first_value, *other_values = values
      first_value = values_max_length.times.collect { |i| _first_value[i] }
      csv_values = first_value.zip(*other_values)
      CSV.open(@result_file, "w") do | csv |
        csv << columns
        csv_values.each { | row |  csv << row }
      end
    end
  end
end
