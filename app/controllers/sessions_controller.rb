class SessionsController < ApplicationController
  
  # make sure the person is logged in for the home action only
  before_filter :login_required, :only => [:home]
  
  # this is the login page. If the user is already logged in the redirect them to the home page
  def new
    redirect_to home_path if logged_in?
  end
  
  # this is the home page, make sure to use the application layout file since we want the menu bar and such
  def home
    respond_to do |format|
      format.html { render :layout => 'application' }
    end 
  end
  
  # renders the user manual, which is located on the server as a packaged file already 
  def get_user_manual
    send_file "public/user_manual/CallLog-UserManual.pdf", :type => "application/pdf"
  end
  
  
  # create our new session. Check to make sure it's a valid username and password and log them in
  def create
    user = User.authenticate(params[:login], params[:password])
    if user
      session[:user_id] = user.id
      # using system generated password. Let them know with a warning message
      if user.system_generated_pw
        flash[:warning] = "You're still using a system generated password. To change it <a href='/change-password'>click here</a>"
      else
        flash[:notice] = "Logged in successfully."
      end
      redirect_to home_path
    else
      flash[:error] = "Invalid login or password."
      render :action => 'new'
    end
  end
  
  # reset a users password if they forgot it and send them an email with the new one
  def reset_password
    
    # find the user who's email matches the one specified
    @user = User.find_by_email(params[:email])
    
    if @user.nil?
      flash[:error] = "No account exists with this email address."
    
    # update the user with a new generated password
    elsif @user.update_attributes(:system_generated_pw => true, 
                                  :password => Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{@user.username}--")[0,6])
      
      # send them an email with the generated password
      UserMailer.deliver_forgotten_password(@user)
      flash[:notice] = "Your password has been reset. An email has been sent containing your new password."
    else
      # looks like we couldn't update for some reason...this will likely never happen
      flash[:error] = "We were unable to reset your password. Please try again."
    end
    
    redirect_to :action => "new"
  end
  
  # log the user out and put them at the login page
  def destroy
    session[:user_id] = nil
    flash[:notice] = "You have been logged out."
    redirect_to root_url
  end
end
