require 'rack'
require 'rack/contrib/try_static'

use Rack::TryStatic,
    root: 'build',
    urls: %w[/],
    try: ['.html', 'index.html', '/index.html']
