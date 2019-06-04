local_gemfile_path = File.join(ENV["PWD"], "Gemfile.local")

if File.exists?(local_gemfile_path)
  ENV["BUNDLE_GEMFILE"] = "Gemfile.local"
end
