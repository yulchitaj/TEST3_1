class SubscriberController < ApplicationController

  def subscribe
    @channels

    if @timetoken == 0
      render :js => make_msg(0)
    end
  end


  def make_msg(timetoken, messages = [])
    if timetoken == 0
      timetoken = (Time.now.to_i * 10000000).to_s
    end
    msg = [ messages, timetoken.to_s].to_json
  end


end
