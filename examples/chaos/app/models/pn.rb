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

  def admin_sub_callback(envelope)
    puts("***** DATA! : #{envelope}")

    ## http://www.pubnub.com/console/?channel=chaos_admin&origin=pubsub.pubnub.com&sub=demo-36&pub=demo-36&cipher=&ssl=false&secret=sec-c-YTk3OGFiNGQtMGExNS00ZDhkLTlkMzItN2UxZTBhMWRiYzk1&auth=

    if envelope.message["type"] == "admin"

      if envelope.message["run_mode"]

        handle_run_mode(envelope)


      elsif envelope.message["output"] == "sub"

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

          # With Channel Attribute

          ##{"type":"admin", "output":"sub", "from":{"fragment":"[{\"action\""}, "channel":"foo"}


          options = Hash.new

          if  envelope.message["from"]["channel"].present?

            # csv string of channels
            frag_channels = envelope.message["from"]["channel"]
            options = {"frag_channels" => frag_channels}

          end

          options["json_encode"] = false

          package_for_q(envelope.message["from"]["fragment"], options)

        end

      end

    end

  end


  def handle_run_mode(envelope)

    if envelope.message["run_mode"]["get"].present?

      # {"type":"admin", "run_mode":{"get":"true"}}

      @pn.publish(:http_sync => false, :message => ProxyConfig.instance.run_modes, :channel => "chaos_admin") do |x|
        puts x
      end

    elsif envelope.message["run_mode"]["set"].present?

      if envelope.message["run_mode"]["set"]

        if envelope.message["mode"]


          # {"type":"admin", "run_mode":"set", "mode":"CORS_HEADERS", "value":false}

          toggle_run_mode(envelope.message["mode"], envelope.message["value"])

        end

      end

    end
  end


  def toggle_run_mode(mode, value)
    if mode.present? && instance_variable_defined?("@#{mode}")

      i = instance_variable_get("@#{mode}")
      i[:enabled] = value

      @pn.publish(:http_sync => false, :message => ProxyConfig.instance.run_modes, :channel => "chaos_admin") do |x|
        puts x
      end

    end


  end


  def package_for_q(message, options = {"json_encode" => true})

    puts "package for q: message: #{message.try(:message)}"

    if message.class == Pubnub::Envelope
      envelope = {"message" => message.message, "channel" => message.channel}
    else
      envelope = {"message" => message}
    end

    #while @block
    #  sleep(0.1)
    #end

    response_data = {"data" => envelope, "json" => options["json_encode"]}

    if options["frag_channels"]
      response_data["channels"] = options["frag_channels"]
    end

    @sub_q.push(response_data)
    @sub_q
    puts "sub_q length is #{@sub_q.length}   "

  end


  def fetch_ready?
    @sub_q.length > 0
  end

  def fetch_q
#    @block = true
#    temp_q = @sub_q.pop
#    @block = false
#    temp_q

#    newq = @sub_q.map {|item| item }
#    newq.pop

    @sub_q.pop

  end

end