class ApplicationController < ActionController::Base
  before_action :find_user

  protected
  def find_user
    @user = params[:user].present? ? User.find(params[:user]) : nil

    @user_name = @user&.name || 'Reader'
  end
end
