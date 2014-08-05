module ApplicationHelper

  def http_sub_status
    ProxyConfig.instance.status[:subscribe][:value]
  end

  def http_time_status
    ProxyConfig.instance.status[:time][:value]
  end

end
