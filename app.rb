require 'sinatra'
require 'sinatra/reloader' if development?

set :haml, format: :html5
set :views, '.'

get '/' do
  haml :index
end
