require 'singleton'
require 'pubnub'

class ProxyConfig
  include Singleton

  def load_run_modes

    @CORS_HEADERS = {
        :enabled => true,
        :options => PnConstants::CORS_HEADERS
    }

    @HTTP_STATUS = {
        :enabled => true,
        :code => 200
    }

  end

  def run_modes

    {:CORS_HEADERS => @CORS_HEADERS,
     :HTTP_STATUS => @HTTP_STATUS
    }

  end


end