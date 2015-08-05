class BoxLoginsController < ApplicationController
  before_action :set_box_login, only: [:show, :edit, :update, :destroy]

  # GET /box_logins
  # GET /box_logins.json
  def index
    @box_login = BoxLogin.first
  end

  # GET /box_logins/1
  # GET /box_logins/1.json
  def show
  end

  # GET /box_logins/new
  def new
    session = RubyBox::Session.new({
      client_id: ENV['BOX_CLIENT_ID'],
      client_secret: ENV['BOX_CLIENT_SECRET']
    })
    authorize_url = session.authorize_url("#{ENV["REDIRECT_HOST"]}/box_logins/callback")
    redirect_to authorize_url
  end

  def callback
    session = RubyBox::Session.new({
       client_id: ENV['BOX_CLIENT_ID'],
       client_secret: ENV['BOX_CLIENT_SECRET']
     })
    @token = session.get_access_token(params[:code])

    @box_login = BoxLogin.first_or_create

    @box_login.details = {token: @token.token, refresh_token: @token.refresh_token}
    @box_login.name = "BoxAuth"
    @box_login.save
    redirect_to root_path
  end


  # DELETE /box_logins/1
  # DELETE /box_logins/1.json
  def destroy
    @box_login.destroy
    respond_to do |format|
      format.html { redirect_to box_logins_url, notice: 'Box login was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_box_login
      @box_login = BoxLogin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def box_login_params
      params.require(:box_login).permit(:name, :details)
    end
end
