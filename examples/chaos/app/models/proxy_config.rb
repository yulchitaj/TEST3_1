require 'singleton'
require 'pubnub'

class ProxyConfig

  include Singleton
  attr_accessor :cors, :http_status, :current_config

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

  end

  def current_config
    {:cors => @cors,
     :http_status => @http_status
    }
  end


  def status
    return http_status
  end

  def cors_headers
    return cors
  end

end