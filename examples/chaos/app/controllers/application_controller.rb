class ApplicationController < ActionController::Base

  include ApplicationHelper

  before_filter :set_pn_vars, :enforce_modes

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def set_pn_vars

    @PN = PN.instance.pn

    @pub_key = params[:pub_key] if params[:pub_key].present?
    @sub_key = params[:sub_key]
    @jsonp = params[:jsonp]
    @timetoken = params[:timetoken].to_i if params[:timetoken].present?
    @channels = params[:channels].split(",") if params[:channels].present?

    @uuid = params[:uuid]
    @pnsdk = params[:pnsdk]

    @PNTIME = "%.10i" % (Time.now.to_f * 10000000)


  end


  def enforce_modes

    puts "CORS: #{cors_headers}"

    if cors_headers
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'GET'
    end

  end



end
