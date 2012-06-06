require 'sinatra'
require 'coffee-script'
require 'haml'
require 'curb'
require 'json'
require 'sass'

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

COMPILERS = {
  js: {coffee: -> js { CoffeeScript.compile js }},
  html: {haml: -> html { Haml::Engine.new(html, format: :html5).render }},
  css: {scss: -> css { Sass.compile(css, syntax: :scss) }, sass: -> css { Sass.compile(css, syntax: :sass) }}
}
TYPES = {js: "application/javascript", html: "text/html", css: "text/css"}

get '/*' do
  if gist_id
    filename = File.basename(params[:captures].first)
    filename = "index.html" if filename.empty?
    extension, name = filename.reverse.split(/\./, 2).map(&:reverse)
    if files.include? filename
      content_type (TYPES[extension.to_sym] || "text/plain")
      return get_raw(filename)
    else
      (COMPILERS[extension.to_sym] || []).each do |source_ext, handler|
        ["#{name}.#{source_ext}", "#{filename}.#{source_ext}"].each do |source_file|
          if files.include? source_file
            content_type (TYPES[extension.to_sym] || "text/plain")
            return handler[get_raw(source_file)]
          end
        end
      end
    end
    status 404
  else
    haml :no_gist_id
  end
end
