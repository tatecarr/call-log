class UserMailer < ActionMailer::Base
  # handles all the mailing logic
  
  def registration_confirmation(user)
    recipients    user.email
    from          "Northeast Arc"
    subject       "Your call log account information"
    body          :user => user
  end
  
  def forgotten_password(user)
    recipients    user.email
    from          "Northeast Arc"
    subject       "Your call log password"
    body          :user => user
  end
  
  def email_feedback(feedback)
    recipients    ["taylor.carr@gordon.edu", "benjamin.vogelzang@gordon.edu", "peter.fraleigh@gordon.edu"]
    from          "Call Log Test User"
    subject       "Call Log Test Feedback"
    body          :feedback => feedback
    content_type  "text/html"
  end
        
end