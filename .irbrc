def __benchmark__(*args)
  if defined?(Rails)
    original_log_level = Rails.logger.level
    Rails.logger.level = Rails.logger.class::UNKNOWN
  end

  case args[0]
  when Numeric
    require "benchmark"

    n = args[0]
    cases = args[1]

    max_label_width = cases.keys.map(&:to_s).map(&:length).max

    Benchmark.bm(max_label_width + 1) do |x|
      cases.each do |label, _proc|
        x.report("#{label}:"){ n.times(&_proc) }
      end
    end
  when Hash
    require "benchmark/ips"

    option_keys     = [:only_comparison]
    non_option_keys = args[0].keys - option_keys

    options = Hash[option_keys.zip(args[0].values_at(*option_keys))]
    cases   = Hash[non_option_keys.zip(args[0].values_at(*non_option_keys))]

    if options[:only_comparison]
      benchmark_options = { :quiet => true }
    else
      benchmark_options = {}
    end

    benchmark = Benchmark.ips(benchmark_options) do |x|
      if options[:only_comparison]
        $stderr.puts "Calculating..."
      end

      cases.each do |label, _proc|
        x.report("#{label}:", _proc)
      end

      unless options[:only_comparison]
        x.compare!
      end
    end

    if options[:only_comparison]
      benchmark.run_comparison
    end
  end
ensure
  if defined?(Rails)
    Rails.logger.level = original_log_level
  end
end

# http://d.hatena.ne.jp/LukeSilvia/20101023/p1
# http://github.com/gmarik/dotfiles/blob/84073cf564b601c99dc4b3b7910bd91234ff94f5/.ruby/lib/gmarik/irb-1.8-history-fix.rb
# http://stackoverflow.com/questions/2065923/irb-history-not-working
begin
  require "irb/ext/save-history"
  module IRB
    # use at_exit hook instead finalizer to save history
    # as finalizer is NOT guaranteed to run
    def HistorySavingAbility.extended(obj); 
      Kernel.at_exit{ HistorySavingAbility.create_finalizer.call }
      obj.load_history #TODO: super?
      obj
    end
  end if IRB::HistorySavingAbility.respond_to?(:create_finalizer)
rescue LoadError => e
  $stderr.puts "ERROR -- #{e.inspect}"
end

# http://rvm.beginrescueend.com/workflow/irbrc/
# for RVM
IRB.conf[:PROMPT_MODE] = :SIMPLE

# ヒストリーを有効にする
IRB.conf[:EVAL_HISTORY] = 1000
IRB.conf[:SAVE_HISTORY] = 100
HISTFILE = "~/.irb_history"
MAXHISTSIZE = 300

begin
  if defined? Readline::HISTORY
    histfile = File::expand_path( HISTFILE )

    if File::exists?( histfile )
      lines = IO::readlines( histfile ).collect {|line| line.chomp}
      puts "Read %d saved history commands from %s." % [ lines.select{|line| line }.size, histfile ] if $DEBUG || $VERBOSE
      Readline::HISTORY.push( *lines )
    else
      puts "History file '%s' was empty or non-existant." % histfile if $DEBUG || $VERBOSE
    end

    Kernel::at_exit {
      lines = Readline::HISTORY.to_a.reverse.uniq.reverse
      lines = lines[ -MAXHISTSIZE, MAXHISTSIZE ] if lines.select{|line| line }.size > MAXHISTSIZE
      $stderr.puts "Saving %d history lines to %s." % [ lines.length, histfile ] if $VERBOSE || $DEBUG

      File::open( histfile, File::WRONLY|File::CREAT|File::TRUNC ) {|ofh|
        lines.each {|line| ofh.puts line }
      }
    }
  end
end

# Log to STDOUT if in Rails
case
when defined?(Rails) && Rails.respond_to?(:logger=)
  Rails.logger              = Logger.new($stdout)
  ActiveRecord::Base.logger = Rails.logger
  ActiveSupport::Deprecation.behavior = :stderr
when ENV.include?("RAILS_ENV") && !Object.const_defined?("RAILS_DEFAULT_LOGGER")
  require "logger"
  RAILS_DEFAULT_LOGGER = Logger.new($stdout)
end

require "rubygems"

begin
  require "wirble"

  Wirble.init
  Wirble.colorize
rescue LoadError => e
  $stderr.puts "ERROR -- #{e.inspect}"
end

begin
  require "hirb"
  require "hirb-unicode"

  Hirb.enable
rescue LoadError => e
  $stderr.puts "ERROR -- #{e.inspect}"
end
