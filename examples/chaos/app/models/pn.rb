require 'singleton'
require 'pubnub'

class PN
  include Singleton

  def initialize

    @sub_q = []

    @pn = Pubnub.new(
        :subscribe_key => 'demo-36',
        :publish_key => 'demo-36',
        :origin => "pubsub.pubnub.com",
        :error_callback => lambda { |msg|
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

    ## http://www.pubnub.com/console/?channel=chaos_admin&origin=pubsub.pubnub.com&sub=demo-36&pub=demo-36&cipher=&ssl=false&secret=sec-c-YTk3OGFiNGQtMGExNS00ZDhkLTlkMzItN2UxZTBhMWRiYzk1&auth=

    ##

    if envelope.message["type"] == "admin"
      if envelope.message["output"] == "sub"

        #             {"type":"admin", "output":"sub", "from":{"ch":"bot"}}

        if envelope.message["from"]["ch"].present?
          @pn.subscribe(:http_sync => false, :channel => envelope.message["from"]["ch"], :callback => method(:put_in_sub_q))

        elsif envelope.message["from"]["fragment"].present?
        put_in_sub_q(package_for_q(envelope.message["from"]["fragment"]))
        end
      end
    end


    while @block
      sleep(0.1)
    end

  end


  def package_for_q(message)
    h = Hash.new
    h["message"] = message
    h
  end

  def put_in_sub_q(envelope)
    if envelope.class == Pubnub::Envelope
      @sub_q.push(envelope.message)
    else
      @sub_q.push(envelope["message"])
    end
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