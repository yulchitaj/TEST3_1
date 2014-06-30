require 'singleton'
require 'packetfu'
require 'pubnub'

class PN
  include Singleton

  def initialize

    load_run_modes

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
        },

        :logger => my_logger
    )

    @pn.subscribe(:http_sync => false, :channel => "chaos_admin", :callback => method(:admin_sub_callback))

    primer = {"type" => "admin", "output" => "sub", "to" => {"ch" => "bot"}}
    #@pn.publish(:http_sync => true, :message => primer, :channel => "chaos_admin")

  end


  def load_run_modes

    @CORS_HEADERS = {
        :enabled => true,
        :options => PnResponse::CORS_HEADERS
    }

  end

  def run_modes

    {:CORS_HEADERS => @CORS_HEADERS}

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

      @pn.publish(:http_sync => false, :message => run_modes, :channel => "chaos_admin") do |x|
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

      @pn.publish(:http_sync => false, :message => run_modes, :channel => "chaos_admin") do |x|
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


  def pkts
    $config = PacketFu::Config.new(PacketFu::Utils.whoami?(:iface=> "en0")).config 	# set interface
                                                                                      #$config = PacketFu::Config.new(:iface=> "wlan0").config   # use this line instead of above if you face `whoami?': uninitialized constant PacketFu::Capture (NameError)

                                                                                      #--> Build TCP/IP

                                                                                      #- Build Ethernet header:---------------------------------------
    pkt = PacketFu::TCPPacket.new(:config => $config , :flavor => "Linux")		# IP header
                                                                                      #     pkt.eth_src = "00:11:22:33:44:55"			# Ether header: Source MAC ; you can use: pkt.eth_header.eth_src
                                                                                      #     pkt.eth_dst = "FF:FF:FF:FF:FF:FF"			# Ether header: Destination MAC ; you can use: pkt.eth_header.eth_dst
    pkt.eth_proto					# Ether header: Protocol ; you can use: pkt.eth_header.eth_proto
                                                                                      #- Build IP header:---------------------------------------
    pkt.ip_v      = 4					# IP header: IPv4 ; you can use: pkt.ip_header.ip_v
    pkt.ip_hl     = 5					# IP header: IP header length ; you can use: pkt.ip_header.ip_hl
    pkt.ip_tos	  = 0					# IP header: Type of service ; you can use: pkt.ip_header.ip_tos
    pkt.ip_len	  = 20					# IP header: Total Length ; you can use: pkt.ip_header.ip_len
    pkt.ip_id						# IP header: Identification ; you can use: pkt.ip_header.ip_id
    pkt.ip_frag   = 0					# IP header: Don't Fragment ; you can use: pkt.ip_header.ip_frag
    pkt.ip_ttl    = 115					# IP header: TTL(64) is the default ; you can use: pkt.ip_header.ip_ttl
    pkt.ip_proto  = 6					# IP header: Protocol = tcp (6) ; you can use: pkt.ip_header.ip_proto
    pkt.ip_sum						# IP header: Header Checksum ; you can use: pkt.ip_header.ip_sum
    pkt.ip_saddr    = "2.2.2.2"				# IP header: Source IP. use $config[:ip_saddr] if you want your real IP ; you can use: pkt.ip_header.ip_saddr
    pkt.ip_daddr    = "10.20.50.45"			# IP header: Destination IP ; you can use: pkt.ip_header.ip_daddr
                                                                                      #- TCP header:---------------------------------------
    pkt.payload   = "Hacked!"				# TCP header: packet header(body)
    pkt.tcp_flags.ack  = 0				# TCP header: Acknowledgment
    pkt.tcp_flags.fin  = 0				# TCP header: Finish
    pkt.tcp_flags.psh  = 0				# TCP header: Push
    pkt.tcp_flags.rst  = 1				# TCP header: Reset
    pkt.tcp_flags.syn  = 1				# TCP header: Synchronize sequence numbers
    pkt.tcp_flags.urg  = 0				# TCP header: Urgent pointer
    pkt.tcp_ecn        = 0				# TCP header: ECHO
    pkt.tcp_win	       = 8192				# TCP header: Window
    pkt.tcp_hlen       = 5				# TCP header: header length
    pkt.tcp_src        = 5555				# TCP header: Source Port (random is the default )
    pkt.tcp_dst        = 4444				# TCP header: Destination Port (make it random/range for general scanning)
    pkt.recalc						# Recalculate/re-build whol pkt (should be at the end)

#--> End of Build TCP/IP

    pkt_to_a = [pkt.to_s]
    return pkt_to_a
  end


  def scan
    pkt_array = pkts.sort_by{rand}
    puts "-" * " [-] Send Syn flag".length + "\n"  + " [-] Send Syn flag " + "\n"

    inj = PacketFu::Inject.new(:iface => $config[:iface] , :config => $config, :promisc => false)
    inj.array_to_wire(:array => pkt_array)		# Send/Inject the packet through connection

    puts " [-] Done" + "\n" + "-" * " [-] Send Syn flag".length
  end


end