class ServerSession
  
  attr_accessor :server
  attr_accessor :last_heartbeat
  
  def message(m, &block)
    if m =~ /^CONNECT (.*) (.*)/
      if @server = Server.where(:identifier => $1, :key => $2).first
        @last_heartbeat = Time.now
        yield ['AUTHOK', { :message => "Authenticated" }]
      else
        @server = nil
        yield ['AUTHFAIL', {:message => "Server details not recognised"}]
      end
    elsif m =~ /^PONG/
      @last_heartbeat = Time.now
      @server.server_messages.all.map { |d| 
        yield ['PUSH', JSON.parse(d.message)]
        d.destroy
      }
    elsif @server
      @server.message(m, &block)
    else
      yield ['ERR']
    end
  end

end