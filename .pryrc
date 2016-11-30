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

begin
  require "hirb"
  require "hirb-unicode"

  # https://github.com/pry/pry/wiki/FAQ#how-can-i-use-the-hirb-gem-with-pry
  # Slightly dirty hack to fully support in-session Hirb.disable/enable toggling
  Hirb::View.instance_eval do
    def enable_output_method
      @output_method = true
      @old_print = Pry.config.print
      Pry.config.print = proc do |*args|
        Hirb::View.view_or_page_output(args[1]) || @old_print.call(*args)
      end
    end

    def disable_output_method
      Pry.config.print = @old_print
      @output_method = nil
    end
  end

  Hirb.enable
rescue LoadError => e
  warn "WARN -- #{e.class.name}: #{e.message} (#{e.backtrace.detect(&/\.pryrc/.method(:===))})"
end
