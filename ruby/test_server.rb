require 'webrick'

configured_port = ARGV[0].to_i

server = WEBrick::HTTPServer.new :Port => configured_port

server.mount_proc '/' do |req, res|
  res.body = 'Hello, world!'
end

server.mount_proc '/timeout' do |req, res|
  params = req.query
  timeout_s = params['s'].to_i
  sleep(timeout_s)
  res.body = 'Hello, world!'
end

trap 'INT' do server.shutdown end

server.start
