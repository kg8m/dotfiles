# frozen_string_literal: true

module Kg8m
  # @param library [String] the library to require
  #
  # @return [void]
  def self.try_to_require(library, fallback: nil, quiet: false)
    require library
  rescue LoadError => e
    if fallback
      try_to_require(fallback, quiet: quiet)
    else
      unless quiet
        warn "WARN -- #{e.class.name}: #{e.message} (#{e.backtrace.join(", ")})"
      end
    end
  end

  module Benchmark
    # @param number_of_trials [Integer] the number of trials to run
    # @param cases_map [Hash<Symbol, Proc>] a hash of labels and procedures to benchmark
    #
    # @return [void]
    def self.bm(number_of_trials, **cases_map)
      require "benchmark"

      cases_map.tap do
        max_label_width = cases_map.keys.map { |key| key.to_s.length }.max

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

    # @param cases_map [Hash<Symbol, Proc>] a hash of labels and procedures to benchmark
    #
    # @return [void]
    def self.ips(**cases_map)
      require "benchmark/ips"

      cases_map.tap do
        @last_result =
          ::Benchmark.ips { |x|
            cases_map.each do |label, procedure|
              x.report(label, procedure)
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
  # @param number_of_trials [Integer] the number of trials to run
  # @param cases_map [Hash<Symbol, Proc>] a hash of labels and procedures to benchmark
  #
  # @return [void]
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

  # @param cases_map [Hash<Symbol, Proc>] a hash of labels and procedures to benchmark
  #
  # @return [void]
  def __benchmark_with_export__(cases_map)
    output_path = "/tmp/benchmark_ips_report.#{Time.now.strftime("%Y%m%d-%H%M%S")}.txt"
    __benchmark__(cases_map)
    report = Kg8m::Benchmark.last_result
    report.generate_json(output_path)
    puts "reported to #{output_path}"
  end
end

if defined?(Rails)
  # Log to STDOUT if in Rails
  Rails.logger = Logger.new($stdout)
  ActiveRecord::Base.logger = Rails.logger

  if Rails.application.respond_to?(:deprecators)
    Rails.application.deprecators.behavior = :stderr
  else
    ActiveSupport::Deprecation.behavior = :stderr
  end

  Kg8m.try_to_require("hirber", quiet: true)
  Kg8m.try_to_require("hirb-unicode", quiet: true)

  if defined?(Hirb)
    if defined?(HirbExt)
      HirbExt.override
    end

    Hirb.enable
  end
end
