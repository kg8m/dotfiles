# frozen_string_literal: true

local_gemfile_path = File.join(ENV.fetch("PWD", nil), "Gemfile.local")

if File.exist?(local_gemfile_path)
  ENV["BUNDLE_GEMFILE"] = "Gemfile.local"
end
