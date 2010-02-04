class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      flash[:notice] = "Logged in successfully."
      redirect_to_target_or_default(root_url)
    else
      flash.now[:error] = "Invalid login or password."
      render :action => 'new'
    end
  end
  
  # reset a users password if they forgot it and send them an email with the new one
  def reset_password
    
    # find the user who's email matches the one specified
    @user = User.find_by_email(params[:email])
    
    # update the user with a new generated password
    if @user.update_attributes(:password => Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{@user.username}--")[0,6])
    
      # send them an email with the generated password
      UserMailer.deliver_forgotten_password(@user)
      flash[:notice] = "Your password has been reset. An email has been sent containing your new password."
    else
      # looks like we couldn't update for some reason...this shouldn't ever happen
      flash[:error] = "We were unable to reset your password."
    end
  end
  
  def destroy
    session[:user_id] = nil
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end
end
