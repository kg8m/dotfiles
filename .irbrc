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
        x.report("#{label}:") { n.times(&procedure) }
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
  end
ensure
  if defined?(Rails)
    Rails.logger.level = original_log_level
  end
end

IRB.conf[:PROMPT_MODE] = :SIMPLE

# Setup history file
HISTORY_DIRPATH  = File.join(ENV.fetch("XDG_DATA_HOME"), "irb")
HISTORY_FILEPATH = File.join(HISTORY_DIRPATH, "history")
MAX_HISTORY_SIZE = 1000

require "fileutils"
FileUtils.mkdir_p(HISTORY_DIRPATH)

IRB.conf[:HISTORY_FILE] = HISTORY_FILEPATH

# Save history at exit and restore it at start because irb doesn't automatically save/restore history.
if File.exists?(HISTORY_FILEPATH)
  File.foreach(HISTORY_FILEPATH) do |line|
    Readline::HISTORY.push(line.chomp)
  end

  Kernel.at_exit do
    lines = Readline::HISTORY.to_a.reverse.uniq.reverse
    lines.slice!(MAX_HISTORY_SIZE, lines.size)
    File.write(HISTORY_FILEPATH, lines.join("\n"))
  end
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
