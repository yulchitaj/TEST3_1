require 'singleton'
require 'pubnub'

class ProxyConfig
  include Singleton

  attr_accessor :cors_headers, :http_status

  def load_default_config

    @cors_headers = {
        :enabled => true,
        :value => PnConstants::CORS_HEADERS
    }

    @http_status = {
        :enabled => true,
        :value => 200
    }

  end

  def run_modes

    {:cors_headers => @cors_headers,
     :http_status => @http_status
    }

  end


  def status
    return http_status[:value]
  end

end