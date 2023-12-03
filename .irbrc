# frozen_string_literal: true

load File.join(ENV.fetch("XDG_CONFIG_HOME"), "irb/common.rb")

IRB.conf[:PROMPT_MODE] = :SIMPLE

# Setup history file
HISTORY_DIRPATH  = File.join(ENV.fetch("XDG_DATA_HOME"), "irb")
HISTORY_FILEPATH = File.join(HISTORY_DIRPATH, "history")
MAX_HISTORY_SIZE = 1000

require "fileutils"
FileUtils.mkdir_p(HISTORY_DIRPATH)

IRB.conf[:HISTORY_FILE] = HISTORY_FILEPATH

# Save history at exit and restore it at start because irb doesn't automatically save/restore history.
if File.exist?(HISTORY_FILEPATH) && defined?(Readline::HISTORY)
  File.foreach(HISTORY_FILEPATH) do |line|
    Readline::HISTORY.push(line.chomp)
  end

  Kernel.at_exit do
    lines = Readline::HISTORY.to_a.reverse.uniq.reverse
    lines.slice!(MAX_HISTORY_SIZE, lines.size)
    File.write(HISTORY_FILEPATH, lines.join("\n"))
  end
end

Kg8m.try_to_require("katakata_irb", quiet: true)

if defined?(KatakataIrb::Types) && KatakataIrb::Types.respond_to?(:loader_type=)
  KatakataIrb::Types.loader_type = :async
end

if defined?(Reline::Face)
  Reline::Face.config(:completion_dialog) do |config|
    config.define :default, background: :blue
    config.define :enhanced, background: :magenta, style: :bold
    config.define :scrollbar, background: :blue
  end
end
