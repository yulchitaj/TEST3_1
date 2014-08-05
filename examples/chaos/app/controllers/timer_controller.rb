class TimerController < ApplicationController
  include ApplicationHelper

  def time
    render :js => make_time, :status => http_time_status
  end

  def make_time
    [@PNTIME.to_i].to_json
  end

end
