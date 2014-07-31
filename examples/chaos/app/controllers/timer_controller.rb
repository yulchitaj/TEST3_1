class TimerController < ApplicationController

  def time
    render :js => make_time, :status => ProxyConfig.instance.status
  end

  def make_time
    [@PNTIME.to_i].to_json
  end

end
