require 'rubygems'
require 'bundler'
require 'coveralls'

Coveralls.wear!

Bundler.setup(:default, :development)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'expertsender_api'

RSpec.configure do |config|
  config.color_enabled = true
end
