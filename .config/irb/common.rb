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
        x.report("#{label}:") { n.times { procedure.call } }
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

if defined?(Rails)
  # Log to STDOUT if in Rails
  Rails.logger = Logger.new($stdout)
  ActiveRecord::Base.logger = Rails.logger
  ActiveSupport::Deprecation.behavior = :stderr

  require "rubygems"

  begin
    require "wirble"

    Wirble.init
    Wirble.colorize
  end

  begin
    require "hirb"
    require "hirb-unicode"

    Hirb.enable
  end
end
