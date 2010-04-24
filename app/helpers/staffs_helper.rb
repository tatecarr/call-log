module StaffsHelper
  
  def expired_certification(staff_courses)
    main_certs = []
    staff_courses.each do |course|
      if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/MAPS/) || course.name.match(/First Aid/)
        if !course.renewal_date.nil? and course.renewal_date < Time.now
          return true
        end
        main_certs << course.name
      end
    end
    return true if main_certs.length < 3
    return false
  end
  
  def certification_warning(staff_courses)
    staff_courses.each do |course|
      if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/MAPS/) || course.name.match(/First Aid/)
        if !course.renewal_date.nil? and course.renewal_date < Time.now + 1.month and course.renewal_date >= Time.now
          return true
        end
      end
    end
    return false
  end
  
  def is_expired(course)
    if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/MAPS/) || course.name.match(/First Aid/)
      if !course.renewal_date.nil? and course.renewal_date < Time.now
        return true
      end
    end
  end
  
  def is_expiring_soon(course)
    if course.name.match(/((Adult)|(American Heart Asso)) CPR/) || course.name.match(/MAPS/) || course.name.match(/First Aid/)
      if !course.renewal_date.nil? and course.renewal_date < Time.now + 1.month and course.renewal_date >= Time.now
        return true
      end
    end
  end
  
end
