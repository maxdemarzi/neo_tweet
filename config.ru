require File.expand_path("../app", __FILE__)
require 'resque/server'

run Rack::URLMap.new \
  "/"       => Sinatra::Application,
  "/resque" => Resque::Server.new