# Applocale

Applocale is a Localization tool,  
It can generates localized file for ios, android or in json format  
The input resource can be 'google sheet' or 'xlsx' or 'csv'

## Installation

**Option1: Install by command:**

    $ gem install applocale

**Option2: by Gemfile:**

add this line to your application's Gemfile:

```ruby
gem 'applocale'
```

And then execute:

    $ bundle



## Usage

	Commands:
		+ init [platform]  # Create Config File, platform: ios | android | json
		+ reverse          # Convert localization string file to xlsx
			[--skip]  	# Skip Error
		+ update           # Download xlsx and convert to localization strings file
		+ update_local     # Convert local xlsx file to localization string file
		+ version     	   # Show the AppLocale verions
		+ findkey [key]    # Findkey and gen report for ios and convert to xlsx
	Optional:
	 	[--path]    # Project Path

## Steps:

For GoogleSheet/XLSX/CSV To localization String files: 
```
Step1: create config file in default path 'AppLocale/AppLocaleFile':
	$ applocale init IOS
Step2: edit config file
Step3: Download and convert xlsx to strings file
	$ applocale update
```
For localization String files To XLSX : 
```
Step1: create config file in default path 'AppLocale/AppLocaleFile':
	$ applocale init IOS
Step2: edit config file
Step3: convert to xlsx 
	$ applocale reverse
```
*** Note that, the special character handling in xlsx is base on strings file(IOS) format.

## ConfigFile:
```ruby
link: [link]	#download link for xlsx, it support google spreadsheet
platform: [android|ios|json]		#It can be android, ios or json
xlsxpath: [xlsxpath]	#local path for save or read xlsx
export_format: [csv|xlsx] # format of downloaded files, default option is xlsx.
google_credentials_path: [google_credentials_path]		#optional: google credentials file path
langlist: 
	[lang1]: [lang1_path]	#localization strings file path for lang1
	[lang2]: [lang2_path]	#localization strings file path for lang2
	[lang3]: [lang3_path]	#localization strings file path for lang3
sheetname:
	[Section1]: #sheetname
		key_str: [header]	#header str for key
		[lang1]: [header]	#header str for lang1
		[lang2]: [header]	#header str for lang2
		[lang3]: [header]	#header str for lang3
	[Section3]: #sheetname
		row: [row]	#first row number
		key: [col]	#col label or number for key
		[lang1]: [col]	#col label or number for lang1
		[lang2]: [col]	#col label or number for lang2
		[lang3]: [col]	#col label or number for lang3
isSkipEmptyKey: [true|false] #whether throw error when key is empty
```
*** Note that, for format in sheetname, it can be either by header or row and col lable

for example:
```ruby
link: "https://docs.google.com/spreadsheets/d/1Wy2gN_DSw-TCU2gPCzqvYxLfFG5fyK5rodXs5MLUy8w"
platform: "ios"
xlsxpath: "string.xlsx"
export_format: "csv"
langlist:
	zh_TW: "IOS/zh_TW.strings"
	zh_CN: "IOS/zh_CN.strings"
	en_US: "IOS/en_US.strings"
sheetname:
	Section1:
		key_str: "Key"
		en_US: "English"
		zh_TW: "Chinese(Traditional)"
		zh_CN: "Chinese(Simplified)"
	Section2:
		key_str: "Key"
		en_US: "English"
		zh_TW: "zh_TW"
		zh_CN: "zh_CN"
	Section3:
		row: "3"
		key: "A"
		en_US: "B"
		zh_TW: "C"
		zh_CN: "D"
isSkipEmptyKey: false
``` 

*** You can also set conversion logic by create method of 'convent_to_locale', 'before_convent_to_locale', 'after_convent_to_locale', 'parse_from_locale', 'before_parse_from_locale', 'after_parse_from_locale', 'is_skip_by_key'



