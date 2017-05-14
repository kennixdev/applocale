# Applocale

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/applocale`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'applocale'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install applocale

## Usage

	Commands:
		+ init [platform]  # Create Config File, platform: ios | android
		+ reverse          # Convert localization string file to xlsx
			[--skip]  	# Skip Error
		+ update           # Download xlsx and convert to localization strings file
			[--local=LOCAL]  # Convert local xlsx file to localization string file


	For XLSX To localization String files: 
	Step1: create config file:
		$ applocale init IOS
	Step2: edit config file:
		link: download link for xlsx, it support google spreadsheet
		platform: It can be android or ios
		keystr: header for Key in xlsx
		langlist: header and path for different language
		xlsxpath: local path for save or read xlsx
	Step3: Download and convert xlsx to strings file
		$ applocale update

	For localization String files To XLSX : 
	Step1: create config file:
		$ applocale init IOS
	Step2: edit config file:
		platform: It can be android or ios
		keystr: header for Key in xlsx
		langlist: header and path for different language
		xlsxpath: local path for save or read xlsx
	Step3: convert to xlsx 
		$ applocale reverse

	*** Note that, the special character handling in xlsx is base on strings file(IOS) format.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/applocale.

