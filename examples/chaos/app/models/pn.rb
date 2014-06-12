require 'singleton'
require 'pubnub'

class PN
  include Singleton

  def initialize

    load_run_modes

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
    #@pn.publish(:http_sync => true, :message => primer, :channel => "chaos_admin")

  end


  def load_run_modes

    @RUN_MODE_CORS_HEADERS = {
        :enabled => true,
        :options => PnResponse::CORS_HEADERS
    }

  end

  def run_modes

    { :CORS_HEADERS => @RUN_MODE_CORS_HEADERS }

  end

  def pn
    @pn
  end

  def admin_sub_callback(envelope)

    ## http://www.pubnub.com/console/?channel=chaos_admin&origin=pubsub.pubnub.com&sub=demo-36&pub=demo-36&cipher=&ssl=false&secret=sec-c-YTk3OGFiNGQtMGExNS00ZDhkLTlkMzItN2UxZTBhMWRiYzk1&auth=

    if envelope.message["type"] == "admin"

      if envelope.message["run_mode"]

        if envelope.message["run_mode"]["get"].present?

          # {"type":"admin", "run_mode":{"get":"true"}}

          @pn.publish(:http_sync => false, :message => run_modes, :channel => "chaos_admin") do |x|
            puts x
        end

        end


      elif envelope.message["output"] == "sub"

        #             {"type":"admin", "output":"sub", "to":{"ch":"bot"}}

        if envelope.message["to"].present?

          if envelope.message["to"]["ch"].present?


          @pn.subscribe(:http_sync => false, :channel => envelope.message["to"]["ch"], :callback => method(:package_for_q))
          #           Send a literal array
          #           {"type":"admin", "output":"sub", "to":{"fragment":"[1,2,3]"}}
          end

        elsif envelope.message["from"]["fragment"].present?

          # Good Literals

          #           {"type":"admin", "output":"sub", "from":{"fragment":"[1,2,3]"}}
          #           [1,2,3]

          #           {"type":"admin", "output":"sub", "from":{"fragment":"[\"1\",2,3]"}}
          #           ["1",2,3]

          #           {"type":"admin", "output":"sub", "from":{"fragment":"\"pizza\""}}
          #           "pizza"

          #           {"type":"admin", "output":"sub", "from":{"fragment":"{\"b\":\"t\"}"}}
          #           {"b":"t"}


          package_for_q(envelope.message["from"]["fragment"], "json_encode" => false)

        end

      end

    end

  end


  def package_for_q(message, options = {"json_encode" => true})

    if message.class == Pubnub::Envelope
      envelope = {"message" => message.message, "channel" => message.channel}
    else
      envelope = {"message" => message}
    end

    while @block
      sleep(0.1)
    end

    response_data = {"data" => envelope, "json" => options["json_encode"]}

    @sub_q.push(response_data)
    @sub_q

  end


  def fetch_ready?
    @sub_q.length > 0
  end

  def fetch_q
    @block = true
    temp_q = @sub_q.pop
    @block = false
    temp_q
  end

end