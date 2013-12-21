class SessionsController < ApplicationController
  def create
    if customer = Customer.authenticate(user_params[:username], user_params[:password])
      session[:customer_id] = customer.id
    else
      flash[:alert] = 'invalid username and password'
    end
    redirect_to :root
  end

  def user_params
    params.permit(:username, :password)
  end
end
