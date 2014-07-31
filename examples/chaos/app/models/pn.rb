require 'singleton'
require 'pubnub'

class PN
  include Singleton

  def initialize

    ProxyConfig.instance.load_run_modes

    @sub_q = []

    my_logger = Logger.new(STDOUT)

    @pn = Pubnub.new(
        :subscribe_key => 'demo-36',
        :publish_key => 'demo-36',
        :origin => "pubsub.pubnub.com",
        :error_callback => lambda { |msg|
          puts "Error callback says: #{msg.inspect}"
        },
        :connect_callback => lambda { |msg|
          puts "CONNECTED: #{msg.inspect}"
        } #,

    #:logger => my_logger
    )

    @pn.subscribe(:http_sync => false, :channel => "chaos_admin", :callback => method(:admin_sub_callback))

    primer = {"type" => "admin", "output" => "sub", "to" => {"ch" => "bot"}}
    #@pn.publish(:http_sync => true, :message => primer, :channel => "chaos_admin")

  end

  def pn
    @pn
  end

  def sub_q
    @sub_q
  end

  def admin_sub_callback(envelope)
    AdminCallback.sub(envelope)
  end

  def fetch_ready?
    @sub_q.length > 0
  end

  def fetch_q
    @sub_q.pop
  end

end