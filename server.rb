Bundler.require

COMPILERS = Hash.new([]).merge(
  js: {coffee: -> js { CoffeeScript.compile js }},
  html: {haml: -> html { Haml::Engine.new(html, format: :html5).render }},
  css: {scss: -> css { Sass.compile(css, syntax: :scss) }, sass: -> css { Sass.compile(css, syntax: :sass) }}
)
TYPES = Hash.new("text/plain").merge(
  js: "application/javascript", html: "text/html", css: "text/css"
)

get '/*' do
  if gist_id
    filename = File.basename(params[:captures].first)
    filename = "index.html" if filename.empty?
    type, content = pull_from_gist(filename)
    if type && content
      content_type type
      content
    else
      status 404
    end
  else
    haml :no_gist_id
  end
end

def pull_from_gist(filename)
  extension = File.extname(filename).sub(/^\./,'')

  if files.keys.include? filename
    [TYPES[extension.to_sym], files[filename]['content']]
  else
    compiler, source = COMPILERS[extension.to_sym].map do |source_ext, compiler|
      found_sources = files.keys & ["#{File.basename(filename,".*")}.#{source_ext}", "#{filename}.#{source_ext}"]
      !found_sources.empty? && [compiler, found_sources.first]
    end.compact.first
    if compiler && source
      [TYPES[extension.to_sym],compiler[files[source]['content']]]
    end
  end
end

def files
  @files ||= if gist_id == 'local'
    Hash[*Dir.glob(File.dirname(__FILE__) + "/local/*").map { |f| [File.basename(f),{'content' => File.read(f)}] }.flatten]
  else
    JSON.parse(fetch("https://api.github.com/gists/#{gist_id}")).fetch('files')
  end
rescue KeyError
  {}
end

def fetch(url)
  Curl::Easy.perform(url) { |e| e.follow_location = true }.body_str
end

def gist_id
  @gist_id ||= request.host[/^(\w+)\./, 1]
end
