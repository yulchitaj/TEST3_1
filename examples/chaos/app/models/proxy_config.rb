require 'singleton'
require 'pubnub'

class ProxyConfig

  include Singleton
  attr_accessor :cors, :http_status, :current_config, :valid_data, :channel_options

  def load_default_config

    @cors = {
        :headers => {
            :enabled => true,
            :value => PnConstants::CORS_HEADERS
        }
    }

    @http_status = {

        :subscribe => {
            :enabled => true,
            :value => 200},

        :time => {
            :enabled => true,
            :value => 200},
    }

    @channel_options = {
        :subscribe => {
            :value => "default"
        }
    }

  end

  def current_config
    {:cors => @cors,
     :http_status => @http_status,
     :channel_options => @channel_options
    }
  end

  def channel_config
    return channel_options
  end

  def status
    return http_status
  end

  def cors_headers
    return cors
  end

end