class ApplicationController < ActionController::Base

  before_filter :set_pn_vars

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_pn_vars

    response.headers['Access-Control-Allow-Origin:'] = '*'
    response.headers['Access-Control-Allow-Methods:'] = 'GET'

    @pub_key = params[:pub_key]
    @sub_key = params[:sub_key]
    @jsonp = params[:jsonp]
    @timetoken = params[:timetoken].to_i
    @channels = params[:channels].split(",")



  end

end
