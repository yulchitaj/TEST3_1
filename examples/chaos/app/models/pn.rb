require 'singleton'
require 'pubnub'

class PN
  include Singleton

  def initialize

    @sub_q = []

    @pn = Pubnub.new(
        :subscribe_key    => 'demo',
        :publish_key      => 'demo',
        :origin           => "pubsub.pubnub.com",
        :error_callback   => lambda { |msg|
          puts "Error callback says: #{msg.inspect}"
        },
        :connect_callback => lambda { |msg|
          puts "CONNECTED: #{msg.inspect}"
        }
    )

    @pn.subscribe(:http_sync => false, :channel => "chaos_admin", :callback => method(:sub_callback))

  end

  def pn
    @pn
  end

  def sub_callback(envelope)

    if envelope.message["type"] == "admin"
      if envelope.message["action"] == "subscribe"
        @pn.subscribe(:http_sync => false, :channel => envelope.message["channel"], :callback => method(:sub_callback))
      end
    end
    while @block
      sleep(0.1)
    end
    @sub_q.push(envelope.message)
  end

  def fetch_ready?
    @sub_q.length > 0
  end

  def fetch_q
    temp_q = @sub_q.clone
    @block = true
    @sub_q = []
    @block = false
    temp_q
  end

end