require 'sinatra'
require 'sinatra/reloader' if development?
require 'coffee-script'
require 'haml'
require 'curb'

set :haml, format: :html5
set :views, 'app'

def gist_id
  request.host[/^(\w+)\./,1]
end

def gist(filename)
  Curl::Easy.perform("http://gist.github.com/raw/#{gist_id}/#{filename}") { |e|
    e.follow_location = true
  }.body_str
end

get '/application.js' do
  coffee gist('application.coffee')
end

get '/favicon.ico' do
end

get '*' do
  haml gist('index.haml')
end
