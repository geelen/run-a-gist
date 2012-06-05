require 'sinatra'
require 'coffee-script'
require 'haml'
require 'curb'
require 'json'

set :haml, format: :html5

def gist_id
  @gist_id ||= request.host[/^(\w+)\./, 1]
end

def fetch(url)
  Curl::Easy.perform(url) { |e| e.follow_location = true }.body_str
end

def get_raw(filename)
  fetch("http://gist.github.com/raw/#{gist_id}/#{filename}")
end

def manifest
  @manifest ||= JSON.parse(fetch("http://gist.github.com/api/v1/json/#{gist_id}"))
end

def files
  @files ||= manifest.fetch('gists').map { |g| g.fetch('files') }.flatten
rescue KeyError
  []
end

HANDLERS = {
  js: {js: -> js { js }, coffee: -> js { CoffeeScript.compile js } },
  html: {html: -> html { html }, haml: -> html { Haml::Engine.new(html).render }}
}

get 'wat' do

end

get '/*' do
  if gist_id
    input = params[:captures].first.empty? ? "index.html" : params[:captures].first
    extension,name = File.basename(input).reverse.split(/\./,2).map(&:reverse)
    (HANDLERS[extension.to_sym] || []).each do |source_ext, handler|
      if files.include? "#{name}.#{source_ext}"
        content_type extension
        return handler[get_raw("#{name}.#{source_ext}")]
      end
    end
  else
    haml :no_gist_id
  end
end
