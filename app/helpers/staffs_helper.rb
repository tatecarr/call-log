module StaffsHelper
  
  def expired_certification(staff_courses)
    staff_courses.each do |course|
      if course.name == "Adult CPR" || course.name == "MAPS" || course.name == "First Aid"
        if !course.renewal_date.nil? and course.renewal_date < Time.now
          return true
        end
      end
    end
    return false
  end
  
  def certification_warning(staff_courses)
    staff_courses.each do |course|
      if course.name == "Adult CPR" || course.name == "MAPS" || course.name == "First Aid"
        if !course.renewal_date.nil? and course.renewal_date < Time.now + 1.month and course.renewal_date >= Time.now
          return true
        end
      end
    end
    return false
  end
end
