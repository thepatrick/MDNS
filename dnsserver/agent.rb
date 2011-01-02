require 'rubygems'
require 'eventmachine'
require 'em-http-request'
 
EventMachine.run {
  http = EventMachine::HttpRequest.new("ws://127.0.0.1:8081/").get :timeout => 0
 
  http.errback { puts "oops" }
  http.callback {
    puts "WebSocket connected!"
    http.send("CONNECT s2.dev.dns.m.ac.nz 9b90b697ecbcd3961758b1f87c13a7ff5f4299af63cca11d3f674750d0f5ae9ccd15102336fff14cdc6e67f94d6f8a5d2d189184e861e832da0d12e7d9284ef3")
  }
 
  http.stream { |msg|
    puts "Recieved: #{msg}"
    if msg == "HEARTBEAT"
      http.send "PONG"
    end
  }
}