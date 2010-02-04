class UserMailer < ActionMailer::Base
  def registration_confirmation(user)
    recipients  user.email
    from        "Northeast Arc"
    subject     "Your call log account information"
    body        :user => user
  end
  
  def forgotten_password(user)
    recipients  user.email
    from        "Northeast Arc"
    subject     "Your temporary password"
    body        :user => user
  end
end