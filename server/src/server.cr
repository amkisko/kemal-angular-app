require "kemal"
require "kemal-basic-auth"

basic_auth "server", "server"

static_headers do |response, filepath, filestat|
  if filepath =~ /\.html$/
    response.headers.add("Access-Control-Allow-Origin", "*")
  end
  response.headers.add("Content-Size", filestat.size.to_s)
end

serve_static({"gzip" => true, "dir_listing" => false})

get "/" do
  "Hello World!"
end

messages = [] of String
sockets = [] of HTTP::WebSocket
ws "/" do |socket|
  puts ">> Socket opened: #{socket}"
  sockets.push socket

  socket.on_message do |message|
    messages.push message
    sockets.each do |a_socket|
      a_socket.send messages.to_json
    end
  end

  socket.on_close do |_|
    sockets.delete(socket)
    puts "<< Socket closed: #{socket}"
  end
end

Kemal.run
