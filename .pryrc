load File.join(ENV.fetch("XDG_CONFIG_HOME"), "irb/common.rb")

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

if defined?(Rails)
  begin
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
  rescue LoadError, NameError => e
    warn "WARN -- #{e.class.name}: #{e.message} (#{e.backtrace.detect(&/\.pryrc/.method(:===))})"
  end
end

local_path = File.expand_path("~/.pryrc.local")
if File.exists?(local_path)
  load local_path
end
