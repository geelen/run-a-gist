require 'sinatra'
require 'sinatra/reloader' if development?
require 'coffee-script'
require 'haml'

set :haml, format: :html5
set :views, File.dirname(__FILE__)

get '/application.js' do
  coffee :application
end

get '*' do
  haml :index
end
