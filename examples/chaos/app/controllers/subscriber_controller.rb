class SubscriberController < ApplicationController

  def subscribe
    @channels

    if @timetoken == 0
      render :js => make_msg(0)
    end
  end


  def make_msg(timetoken, messages = [])
    if timetoken == 0
      t = Time.now
      timetoken = "%.10i" % (t.to_f * 10000000)
    end
    msg = [ messages, timetoken.to_s].to_json
  end


end
