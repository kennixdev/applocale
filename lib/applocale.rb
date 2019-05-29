require "applocale/version"
require 'thor'
require 'applocale/Command/init'

module Applocale
  # Your code goes here...
end

if ARGV.length > 0
  Applocale::Command::Init.start(ARGV)
end

