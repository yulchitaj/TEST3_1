class AdminCallback

  @@pn = PN.instance.pn

  def self.sub(envelope)
    puts("***** DATA! : #{envelope}")

    ## http://www.pubnub.com/console/?channel=chaos_admin&origin=pubsub.pubnub.com&sub=demo-36&pub=demo-36&cipher=&ssl=false&secret=sec-c-YTk3OGFiNGQtMGExNS00ZDhkLTlkMzItN2UxZTBhMWRiYzk1&auth=

    if envelope.message["type"] == "admin"

      if envelope.message["run_mode"]

        handle_run_mode(envelope)


      elsif envelope.message["output"] == "sub"

        #             {"type":"admin", "output":"sub", "to":{"ch":"bot"}}

        if envelope.message["to"].present?

          if envelope.message["to"]["ch"].present?


            @@pn.subscribe(:http_sync => false, :channel => envelope.message["to"]["ch"], :callback => method(:package_for_q))

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


  def self.package_for_q(message, options = {"json_encode" => true})

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

    PN.instance.sub_q.push(response_data)

    puts "sub_q length is #{@sub_q.length}   "

  end

  def self.handle_run_mode(envelope)

    if envelope.message["run_mode"]["get"].present?

      # {"type":"admin", "run_mode":{"get":"true"}}

      @@pn.publish(:http_sync => false, :message => ProxyConfig.instance.run_modes, :channel => "chaos_admin") do |x|
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

  def self.toggle_run_mode(mode, value)
    if mode.present? && instance_variable_defined?("@#{mode}")

      i = instance_variable_get("@#{mode}")
      i[:enabled] = value

      @@pn.publish(:http_sync => false, :message => ProxyConfig.instance.run_modes, :channel => "chaos_admin") do |x|
        puts x
      end
    end
  end

end