ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'logger' # Required explicitly for Ruby 3.2+ (no longer auto-loaded)
require 'bundler/setup' # Set up gems listed in the Gemfile.
