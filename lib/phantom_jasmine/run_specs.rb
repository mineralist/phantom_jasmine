$:.unshift(ENV['JASMINE_GEM_PATH']) if ENV['JASMINE_GEM_PATH'] # for gem testing purposes

require 'rubygems'
require 'jasmine'
if Jasmine::Dependencies.rspec2?
  require 'rspec'
else
  require 'spec'
end
require 'jasmine/runners/phantom'
require 'phantomjs-mac' if RUBY_PLATFORM.downcase.include?('darwin')

jasmine_yml = File.join(Dir.pwd, 'spec', 'javascripts', 'support', 'jasmine.yml')
if File.exist?(jasmine_yml)
end

Jasmine.load_configuration_from_yaml

config = Jasmine.config

server = Jasmine::Server.new(config.port, Jasmine::Application.app(config))
t = Thread.new do
  begin
    server.start
  rescue ChildProcess::TimeoutError
  end
  # # ignore bad exits
end
t.abort_on_exception = true
Jasmine::wait_for_listener(config.port, "jasmine server")
puts "jasmine server started."

results_processor = Jasmine::ResultsProcessor.new(config)
results = Jasmine::Runners::Phantom.new(config.port, results_processor, config.result_batch_size).run
formatter = Jasmine::RspecFormatter.new
formatter.format_results(results)