require 'singleton'
require 'pubnub'

class PN

  include Singleton

  def initialize

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
  end

  def time

    @pn.time(:http_sync => true)

  end
  # To change this template use File | Settings | File Templates.
end