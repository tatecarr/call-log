#-----------------------------------------------------------------------------------
# staffs_helper.rb
#
# Handles all staff helper methods of the call log system
#
# Written By: Ben Vogelzang 1/28/10
#
#-----------------------------------------------------------------------------------

module StaffsHelper
  
  # determine whether a staff member has any expired courses or is missing any
  #
  # @param - an array of course objects
  #
  # @return - true if they have any expired courses or are missing any false if otherwise 
  #
  def expired_certification(staff_courses)
    main_certs = []
    staff_courses.each do |course|
      if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/First Aid/)
        if !course.renewal_date.nil? and course.renewal_date < Time.now
          return true
        end
        main_certs << course.name
      end
    end
    return true if main_certs.length < 2
    return false
  end
  
  # determine whether a staff member has any course which will expire within a month from today
  #
  # @param - an array of course objects
  #
  # @return - true if any of the courses will expire within a month false if otherwise 
  #
  def certification_warning(staff_courses)
    staff_courses.each do |course|
      if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/MAPS/) || course.name.match(/First Aid/)
        if (!course.renewal_date.nil? and course.renewal_date < Time.now + 1.month and course.renewal_date >= Time.now) or (!course.renewal_date.nil? and course.renewal_date < Time.now and course.name.match(/MAPS/))
          return true
        end
      end
    end
    return false
  end
  
  # determine whether a course is expired
  #
  # @param - a course object
  #
  # @return - true if the course is expired and false if otherwise
  #
  def is_expired(course)
    if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/MAPS/) || course.name.match(/First Aid/)
      if !course.renewal_date.nil? and course.renewal_date < Time.now
        return true
      end
    end
  end
  
  # determine whether a course will expire within the month
  #
  # @param - a course object
  #
  # @return - true if the course will expire within the month and false if otherwise
  #
  def is_expiring_soon(course)
    if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/MAPS/) || course.name.match(/First Aid/)
      if !course.renewal_date.nil? and course.renewal_date < Time.now + 1.month and course.renewal_date >= Time.now
        return true
      end
    end
  end
  
end
