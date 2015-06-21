$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'yaml'
$config = YAML.load(File.read('spec/config.yml'))

require 'compact_index'
require 'support/database'
