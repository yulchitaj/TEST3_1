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

    @pn.subscribe(:http_sync => false, :channel => "chaos_admin", :callback => method(:admin_sub_callback))

    primer = {"type" => "admin", "output" => "sub", "to" => {"ch" => "bot"}}
    @pn.publish(:http_sync => true, :message => primer, :channel => "chaos_admin")

  end

  def pn
    @pn
  end

  def admin_sub_callback(envelope)

    ## http://www.pubnub.com/console/?channel=chaos_admin&origin=pubsub.pubnub.com&sub=demo-36&pub=demo-36&cipher=&ssl=false&secret=sec-c-YTk3OGFiNGQtMGExNS00ZDhkLTlkMzItN2UxZTBhMWRiYzk1&auth=

    if envelope.message["type"] == "admin"
      if envelope.message["output"] == "sub"

        #             {"type":"admin", "output":"sub", "from":{"ch":"bot"}}

        if envelope.message["to"]["ch"].present?


          @pn.subscribe(:http_sync => false, :channel => envelope.message["to"]["ch"], :callback => method(:package_for_q))
          #           Send a literal array
          #           {"type":"admin", "output":"sub", "to":{"fragment":"[1,2,3]"}}

        elsif envelope.message["from"]["fragment"].present?

          package_for_q(envelope.message["from"]["fragment"], "json_encode" => false)
        end
      end
    end


    while @block
      sleep(0.1)
    end

  end


  def package_for_q(message, options = {"json_encode" => true})

    if message.class == Pubnub::Envelope
      envelope = {"message" => message.message}
    else
      envelope = {"message" => message}
    end

    @sub_q.push({"data" => envelope["message"], "json" => options["json_encode"]})
    @sub_q
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