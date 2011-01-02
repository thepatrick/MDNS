require 'eventmachine'
require 'em-websocket'
require 'json'

# monkey patch em-websocket's connection object to add the bits we need
class EventMachine::WebSocket::Connection
  attr_accessor :sending_timer
  
  def session_id
    [request['Sec-WebSocket-Key1'], request['Sec-WebSocket-Key2'], request['Third-Key']].hash.to_s
  end
end

server_sessions = {}

EventMachine::run do
  
  restart_txt_filename = File.join(RAILS_ROOT, 'tmp', 'restart.txt')
  restart_txt_mtime = (File.exists?(restart_txt_filename) && File.mtime(restart_txt_filename)) || 0
  restart_txt_watcher = EventMachine::PeriodicTimer.new(1) do
    if restart_txt_mtime != (new_mtime = ((File.exists?(restart_txt_filename) && File.mtime(restart_txt_filename)) || 0))
      restart_txt_mtime = new_mtime
      
      # Restart this process
      puts "DEBUG: restart.txt modified, restarting..."
      `#{RAILS_ROOT}/script/websocket-server restart`
    end
  end
  
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8081) do |ws|
    
    # Keep track of the number of active connections
    active_connections = 0
    
    ws.onopen do
      active_connections += 1
      server_sessions[ws.session_id] = ServerSession.new
      
      # setup sender on a periodic timer
      # ws.sending_timer = EventMachine::PeriodicTimer.new(0.5) do
      #   server = session.reload.server
      #   server && ServerQueuedMessage.for(server).each do |queued_message|
      #     ws.send "~m~#{queued_message.message_json.length + 3}~m~~j~#{queued_message.message_json}"
      #     queued_message.delete
      #   end
      # end
      
    end
    
    ws.onclose do
      ws.sending_timer && ws.sending_timer.cancel
      active_connections -= 1
      server_sessions[ws.session_id] = nil
    end
    
    # Extract, decode and handle incoming messages
    ws.onmessage do |chunks|
      puts chunks
      session = server_sessions[ws.session_id]
      session && session.message(message) do |response|
       jsond = response.to_json
       ws.send jsond
      end
    end
    
  end
end
