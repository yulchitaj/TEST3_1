class AdminCallback

  @@pn = PN.instance.pn
  @@config = ProxyConfig.instance


  def self.sub(envelope)
    puts("***** DATA! : #{envelope}")

    ## http://www.pubnub.com/console/?channel=chaos_admin&origin=pubsub.pubnub.com&sub=demo-36&pub=demo-36&cipher=&ssl=false&secret=sec-c-YTk3OGFiNGQtMGExNS00ZDhkLTlkMzItN2UxZTBhMWRiYzk1&auth=

    if envelope.message["type"] == "admin"

      if envelope.message["run_mode"]

        handle_config(envelope)


      elsif envelope.message["output"] == "sub"

        #             {"type":"admin", "output":"sub", "to":{"ch":"bot"}}

        if envelope.message["to"].present?
          if envelope.message["to"]["ch"].present?


            @@pn.subscribe(:http_sync => false, :channel => envelope.message["to"]["ch"], :callback => method(:package_for_q))

          end

        elsif envelope.message["from"]["fragment"].present?

          # Good Literals

          #           {"type":"admin", "output":"sub", "from":{"fragment":"[1,2,3]"}}
          #           ... {"fragment":"[\"1\",2,3]"}, {"fragment":"{\"b\":\"t\"}"}, {"fragment":"\"pizza\""}

          # TODO: Implement Channel Options
          # With Channel Attribute
          ##{"type":"admin", "output":"sub", "from":{"fragment":"[{\"action\""}, "channel":"foo"}


          options = Hash.new

          options["well_formed_json"] = false
          options["from"] = "fragment"
          package_for_q(envelope.message["from"]["fragment"], options)

        elsif envelope.message["from"]["response"].present?
          options = Hash.new

          options["well_formed_json"] = false
          options["from"] = "response"
          package_for_q(envelope.message["from"]["response"], options)

        end

      end

    end
  end


  def self.package_for_q(message, options = {"well_formed_json" => true})
    # puts "package for q: message: #{message.try(:message)}"

    if message.class == Pubnub::Envelope # If its a native PN message, ie, forwarded from subscribe

      payload = Payload.new(:from => "envelope",
                            :well_formed_json => options["well_formed_json"],
                            :message => message.message,
                            :channels => message.channel)

    elsif options["from"] == "fragment" # custom message element fragment

      payload = Payload.new(:from => "fragment",
                            :well_formed_json => options["well_formed_json"],
                            :message => message)

    elsif options["from"] == "response" # custom full blown server response
      payload = Payload.new(:from => "response",
                            :well_formed_json => options["well_formed_json"],
                            :message => message)

    end

    PN.instance.sub_q.push(payload)

    puts "sub_q length is #{@sub_q.length}   "

  end


  def self.handle_config(envelope)

    if envelope.message["run_mode"]["get"].present?
      get_config
    elsif envelope.message["run_mode"]["set"].present?
      set_config(envelope)
    end

  end

  def self.set_config(envelope)
    if envelope.message["run_mode"]["set"]

      if obj = envelope.message["obj"]

        # {"type":"admin", "run_mode":"set", "mode":"cors_headers", "value":false}

        key = envelope.message["key"]
        value = envelope.message["value"]
        proxy_config_object = @@config.instance_variable_get("@#{obj}")
        service = envelope.message["service"]

        if proxy_config_object && service && key
          proxy_config_object[service.to_sym][key.to_sym] = value
          get_config
        end
      end
    end
  end

  def self.get_config
    # {"type":"admin", "run_mode":{"get":"true"}}
    @@pn.publish(:http_sync => false, :message => ProxyConfig.instance.current_config, :channel => "chaos_admin") do |x|
      puts x
    end
  end


end
