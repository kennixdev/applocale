require "applocale/version"
require 'thor'
require 'applocale/Command/init'

module Applocale
  # Your code goes here...
end

Applocale::Command::Init.start(ARGV)
