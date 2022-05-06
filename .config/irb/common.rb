# frozen_string_literal: true

module Kg8m
  module Benchmark
    def self.bm(number_of_trials, **cases_map)
      cases_map.tap do
        require "benchmark"

        max_label_width = cases_map.keys.map(&:to_s).map(&:length).max

        @last_result =
          ::Benchmark.bm(max_label_width + 1) do |x|
            cases_map.each do |label, procedure|
              x.report("#{label}:") { number_of_trials.times { procedure.call } }
            end
          end

        puts ""
        show_note
      end
    end

    def self.ips(**cases_map)
      cases_map.tap do
        require "benchmark/ips"

        @last_result =
          ::Benchmark.ips {|x|
            cases_map.each do |label, procedure|
              x.report("#{label}:", procedure)
            end
            x.compare!
          }

        show_note
      end
    end

    def self.last_result
      @last_result
    end

    class << self
      private

      def show_note
        puts "NOTE: The last benchmark result can be seen with `#{name}.last_result`.\n\n"
      end
    end
  end
end

class Object
  def __benchmark__(number_of_trials = nil, **cases_map)
    if defined?(Rails)
      original_log_level = Rails.logger.level
      Rails.logger.level = Rails.logger.class::UNKNOWN
    end

    if number_of_trials
      Kg8m::Benchmark.bm(number_of_trials, **cases_map)
    else
      Kg8m::Benchmark.ips(**cases_map)
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
end

if defined?(Rails)
  # Log to STDOUT if in Rails
  Rails.logger = Logger.new($stdout)
  ActiveRecord::Base.logger = Rails.logger
  ActiveSupport::Deprecation.behavior = :stderr

  begin
    require "hirb"
    require "hirb-unicode"

    Hirb.enable
  end
end
