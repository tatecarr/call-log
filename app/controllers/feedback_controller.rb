class FeedbackController < ApplicationController
  
  def index
    
    if params[:app_page] != nil && params[:app_page] != ""
      @email_sent = true
      
      @feedback = { "app_page",           params[:app_page].to_s,
                    "what_function",      params[:what_function].to_s,
                    "what_input",         params[:what_input].to_s,
                    "supposed_to_happen", params[:supposed_to_happen].to_s,
                    "actually_happened",  params[:actually_happened].to_s,
                    "suggestions",        params[:suggestions].to_s }
      
      puts @feedback["app_page"]
      puts @feedback["what_function"]
      puts @feedback["what_input"]
      puts @feedback["supposed_to_happen"]
      puts @feedback["actually_happened"]
      puts @feedback["suggestions"]
      
      UserMailer.deliver_email_feedback(@feedback)
      
    end
    
  end
  
end

