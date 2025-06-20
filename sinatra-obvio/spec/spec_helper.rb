ENV['RACK_ENV'] ||= 'test'

require 'yaml'
require 'active_record'
require 'rack/test'

require_relative '../server'

db_config = YAML.load_file(File.expand_path('../config/database.yml', __dir__), aliases: true)
ActiveRecord::Base.establish_connection(db_config[ENV['RACK_ENV']])

RSpec.configure do |config|
  config.around(:each) do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
