#-----------------------------------------------------------------------------------
# application_helper.rb
#
# Handles all application wide helper methods of the call log system
#
# Written By: Taylor Carr 1/28/10
#
#-----------------------------------------------------------------------------------

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # this is a helper to enable multiple autocomplete forms on the same page
  # taken from a forum online. Wraps the autocomplete code and defines a new id name
  def my_text_field_with_auto_complete(object, method, tag_options = {}, completion_options = {})
    if(tag_options[:index])
      tag_name = "#{object}_#{tag_options[:index]}_#{method}"

    else
      tag_name = "#{object}_#{method}"
    end

    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
      text_field(object, method, tag_options) +
      content_tag("div", "", :id => tag_name + "_auto_complete", :class => "auto_complete") +
      auto_complete_field(tag_name, { :url => { :action => "auto_complete_for_#{object}_#{method}" } }.update(completion_options))
  end
  
  
  # get the important courses that the person has
  #
  # @param staff - the Staff object you want the important courses for
  # @param array - indicates whether to return an array of course objects (TRUE) or an array of course names (FALSE)
  #                defaults to course names
  #
  # @return - an array of course objects or an array of course names
  def important_courses(staff, array = false)
    courses = []
    for course in staff.courses
      if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/MAPS/) || course.name.match(/First Aid/)
        if array
          courses << course
        else
          courses << course.name
        end
      end
    end
    courses
  end

end
