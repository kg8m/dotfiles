Pry.config.prompt = proc { ">> " }

# Log to STDOUT if in Rails
case
when defined?(Rails) && Rails.env.development?
  Rails.logger              = Logger.new($stdout)
  ActiveRecord::Base.logger = Rails.logger
  ActiveSupport::Deprecation.behavior = :stderr
when ENV.include?("RAILS_ENV") && ENV["RAILS_ENV"] == "development" && !Object.const_defined?("RAILS_DEFAULT_LOGGER")
  require "logger"
  RAILS_DEFAULT_LOGGER = Logger.new($stdout)
end
