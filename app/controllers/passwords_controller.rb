# Kebab 2.0
#
# Author::    Onur Özgür ÖZKAN <onur.ozgur.ozkan@lab2023.com>
# Copyright:: Copyright (c) 2011 lab2023 - internet technologies
# License::   Distributes under MIT

# Password Controller
class PasswordsController < ApplicationController
  skip_before_filter :authenticate, only: [:create]
  skip_before_filter :authorize

  # POST/passwords
  # KBBTODO #62 send activation for forget password
  def create
    @user = @current_tenant.users.find_by_email(params[:email])
    new_password = rand(10000000000000).floor.to_s(36)
    @user.password = new_password
    if @user.save
      UserMailer.forget_password(@user).deliver
    else
      @response[:success] = false
      @status = :unprocessable_entity
    end

    render json: @response, status: @status
  end

  # PUT/passwords
  def update
    @user = @current_tenant.users.find(session[:user_id])
    if @user.authenticate(params[:password]) && @user.update_attributes({password: params[:new_password]})
      render json: @response
    else
      render json: {success: false}
    end
  end

end
