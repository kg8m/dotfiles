class Object
  def __benchmark__(labels_and_procs)
    require "benchmark/ips"

    Benchmark.ips do |x|
      labels_and_procs.each do |label, _proc|
        x.report("#{label}:"){ _proc.call }
      end
    end
  end
end

# http://d.hatena.ne.jp/LukeSilvia/20101023/p1
# http://github.com/gmarik/dotfiles/blob/84073cf564b601c99dc4b3b7910bd91234ff94f5/.ruby/lib/gmarik/irb-1.8-history-fix.rb
# http://stackoverflow.com/questions/2065923/irb-history-not-working
require 'irb/ext/save-history'
module IRB
  # use at_exit hook instead finalizer to save history
  # as finalizer is NOT guaranteed to run
  def HistorySavingAbility.extended(obj); 
    Kernel.at_exit{ HistorySavingAbility.create_finalizer.call }
    obj.load_history #TODO: super?
    obj
  end
end if IRB::HistorySavingAbility.respond_to?(:create_finalizer)

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
when defined?(Rails) && Rails.env.development?
  ActiveRecord::Base.logger = Logger.new($stdout)
when ENV.include?("RAILS_ENV") && ENV["RAILS_ENV"] == "development" && !Object.const_defined?("RAILS_DEFAULT_LOGGER")
  require "logger"
  RAILS_DEFAULT_LOGGER = Logger.new($stdout)
end

require 'rubygems'
require 'wirble'
require 'hirb'
require 'hirb-unicode'

Wirble.init
Wirble.colorize

Hirb.enable
