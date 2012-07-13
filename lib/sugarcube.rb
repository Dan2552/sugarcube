unless defined?(Motion::Project::Config)
  raise "sugarcube must be required within a RubyMotion project Rakefile."
end


Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'sugarcube/**/*.rb')).reverse.each do |file|
    app.files.unshift(file)
  end
end
