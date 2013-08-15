require 'rubygems'
['sparql', 'linkeddata', 'thin', 'rack/sparql', 'rack/server', 'uri', 'webrick'].each {|x| require x}
include WEBrick

HTTPServer.new(
  :Port            => 8082,
  :DocumentRoot    => File.expand_path("..",Dir.pwd)
).start

