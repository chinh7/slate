require 'rack'
require 'rack/contrib/try_static'

use Rack::TryStatic,
    root: 'build',
    urls: %w[/],
    try: ['.html', 'index.html', '/index.html']


run lambda{ |env|
      four_oh_four_page = File.expand_path("../build/404.html", __FILE__)
        [ 404, { 'Content-Type'  => 'text/html'}, [ File.read(four_oh_four_page) ]]
    }
