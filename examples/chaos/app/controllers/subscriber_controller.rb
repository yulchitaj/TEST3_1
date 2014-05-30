class SubscriberController < ApplicationController

  def subscribe
      render :js => make_msg(0)
    end
  end


  def make_msg(timetoken, messages = [])

      timetoken = @PNTIME

    [ messages, timetoken.to_s].to_json

end
