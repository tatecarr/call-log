@staffs.each do |staff|
	
	pdf.text staff.first_name + " " + staff.last_name
end