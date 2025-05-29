require 'yaml'
require 'active_record'

require_relative '../server'

ENV['RACK_ENV'] ||= 'test'

db_config = YAML.load_file(File.expand_path('../../config/database.yml', __FILE__), aliases: true)
ActiveRecord::Base.establish_connection(db_config[ENV['RACK_ENV']])

