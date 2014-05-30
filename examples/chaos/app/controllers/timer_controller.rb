class TimerController < ApplicationController

  def time
    render :js => make_time
  end

  def make_time
    [@PNTIME.to_i].to_json
  end

end
