# Sets the pdf to landscape view
pdf = Prawn::Document.new(:page_layout => :landscape)

unless @staffs.blank?

pdf.table @staffs.map { |staff|
  # The following variables are being used to define the contents of each of the columns of the staff report since there are multiple 
  # values for each column on some accounts.
  staff_id = "#{staff.staff_id}"
  first_name = "#{staff.first_name}"
  last_name = "#{staff.last_name}"
  doh = "#{staff.doh.strftime("%m/%d/%Y")}"
  cell_phone = "#{staff.cell_number}"
  home_phone = "#{staff.home_number}"
  work_phone = "#{staff.work_number}"
  exp_prefs = staff.staff_info.experience_prefs(:plain) == "Click here to add experience and preferences info." ? "" : "#{staff.staff_info.experience_prefs(:plain)}"
  skill_limit = staff.staff_info.skills_limits(:plain) == "Click here to add skills and limits info." ? "" : "#{staff.staff_info.skills_limits(:plain)}"
  courses = "#{staff.courses.map {|course| course.name }.join(', ')}"
  availability = staff.staff_info.schedule_availability(:plain) == "Click here to add schedule and availability info." ? "": "#{staff.staff_info.schedule_availability(:plain)}"
  notes = staff.staff_info.contact_notes(:plain) == "Click here to add conact info and other notes." ? "" : "#{staff.staff_info.contact_notes(:plain)}"
  
  [first_name + " " + last_name + "\nDOH " + doh, "C " + cell_phone + "\nH " + home_phone + "\nW " + work_phone, exp_prefs, skill_limit, courses, availability, notes ]
},
:border_style => :grid,
:row_colors => ["FFFFFF","DDDDDD"],
:headers => ["Name\nDate of Hire", "Contact Information", "Experience and Prefernces", "Skills and\n Limitations", "Trainings", "Schedule Availability", "Notes"],
:align => { 0 => :left, 1 => :left, 2 => :left, 3 => :left, 4 => :left, 5 => :left, 6 => :left },
:column_widths => { 0 => 100, 1 => 100, 2 => 110, 3 => 105, 4 => 105, 5 => 105, 6 => 100 },
:font_size => 10

else
	pdf.text "There are no staff members to print."
end