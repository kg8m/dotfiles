prompt_procs = [
  proc { ">> " },
  proc { "++ " },
]

if Pry::Prompt.respond_to?(:new)
  begin
    Pry.config.prompt = Pry::Prompt.new(:simple, "Simple Prompt", prompt_procs)
  rescue ArgumentError
    Pry.config.prompt = prompt_procs
  end
else
  Pry.config.prompt = prompt_procs
end

# Log to STDOUT if in Rails
Rails.logger = Logger.new($stdout)
ActiveRecord::Base.logger = Rails.logger
ActiveSupport::Deprecation.behavior = :stderr

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

def __benchmark__(n = nil, **cases_map)
  if defined?(Rails)
    original_log_level = Rails.logger.level
    Rails.logger.level = Rails.logger.class::UNKNOWN
  end

  if n
    require "benchmark"

    max_label_width = cases_map.keys.map(&:to_s).map(&:length).max

    Benchmark.bm(max_label_width + 1) do |x|
      cases_map.each do |label, procedure|
        x.report("#{label}:"){ n.times(&procedure) }
      end
    end
  else
    require "benchmark/ips"

    Benchmark.ips do |x|
      cases_map.each do |label, procedure|
        x.report("#{label}:", procedure)
      end
      x.compare!
    end
  end
ensure
  if defined?(Rails)
    Rails.logger.level = original_log_level
  end
end

def __benchmark_with_export__(cases_map)
  output_path = "/tmp/benchmark_ips_report.#{Time.now.strftime("%Y%m%d-%H%M%S")}.txt"
  report = __benchmark__(cases_map)
  report.generate_json(output_path)
  puts "reported to #{output_path}"
  report
end

local_path = File.expand_path("~/.pryrc.local")
if File.exists?(local_path)
  load local_path
end
