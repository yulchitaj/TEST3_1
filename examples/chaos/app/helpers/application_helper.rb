module ApplicationHelper

  def http_sub_status
    ProxyConfig.instance.status[:subscribe][:value]
  end

  def http_time_status
    ProxyConfig.instance.status[:time][:value]
  end

  def cors_headers
    ProxyConfig.instance.cors[:headers][:enabled]
  end

  def current_config
    ProxyConfig.instance.current_config
  end

  def channel_options
    ProxyConfig.instance.channel_options[:subscribe][:value]
  end

end
