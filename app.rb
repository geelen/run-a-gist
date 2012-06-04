require 'sinatra'
require 'sinatra/reloader' if development?
require 'coffee-script'
require 'haml'

set :haml, format: :html5
set :views, '.'

get '/' do
  haml :index
end

get '/application.js' do
  coffee :application
end
