# This is a method that helps to create and format each table needed for 
# the different sections of staff in the database it calls upon a 
# collection, which is a given array of a certain staff type, and then 
# maps it to allow quick iteration over it and allows the following 
# methods to be called on each and every item in the array

def table_draw(pdf, collection, collection_name, 
		headings = ["Name", "Position", "Trainings", "Phone Number(s)"])
		
		# checks to see if the collection passed is empty and will return
		# the following if it is this is used in case there are no relief
		# or overtime (or staff at all) assigned to a house
		
		if collection.empty?
			pdf.text "No #{collection_name} are assigned to this house profile.", :style => :italic, :size => 10
		else
			pdf.table collection.map { |house_staff| 
				staff = Staff.find_by_id(house_staff.id)
				[
				   	staff.first_name + " " + staff.last_name,
				    house_staff.position_name,
					"CPR: 12/04/11 \n Cert2:04/28/12",
					"Home: " + staff.home_number + "\nCell: " + staff.cell_number
				]
			},	
				:border_style => :grid,
				:row_colors => ["FFFFFF","DDDDDD"],
				:headers => ["Name", "Position", "Trainings", 
					"Phone Number(s)"],
				:align => { 0 => :left, 1 => :left, 2 => :left,
				 	3 => :left },
				:column_widths => { 0 => 140, 1 => 140, 2 => 140,
				 	3 => 140 }
		end
end

@houses.each_with_index do |house, i|
	pdf.text "#{house.name}", :spacing => 16, :align => :center
	pdf.text "#{house.address}", :spacing => 16, :align	=> :center
	pdf.text "#{house.phone1} // #{house.phone2} // Fax - #{house.fax}", 
				:spacing => 16, :align	=> :center

	# Provides spacing based on 15 pdf specific units
	pdf.move_down(15)

# The following sections each have a call to find and put into an array 
# a certain staff type based on the position name given they are then 
# called by the above table_draw method where their information (based 
# on the house_staff database) is then placed neatly into tables

pdf.text "Directors", :style => :bold, :size => 12
directors = HouseStaff.find(:all, :conditions => ['bu_code = ? 
				AND position_name IN (?)', house.bu_code, 
				["Residential Director", "Nurse Case Manager", "Clinical Manager", "Assistant House Director", "House Coordinator"]])
table_draw pdf, directors, "Directors"

pdf.move_down(15)

pdf.text "Managers", :style => :bold, :size => 12
managers = HouseStaff.find(:all, :conditions => ['bu_code = ? 
				AND position_name = ?', house.bu_code, 
				"House Manager"])
table_draw pdf, managers, "Managers"

pdf.move_down(15)

pdf.text "Skills Instructors", :style => :bold, :size => 12
skills_instructors = HouseStaff.find(:all, :conditions => ['bu_code = ? 
				AND position_name = ?', house.bu_code, 
				"Skills Instructor"])
table_draw pdf, skills_instructors, "Skills Instructors"

pdf.move_down(15)

pdf.text "Overnight Staff", :style => :bold, :size => 12
overnights = HouseStaff.find(:all, :conditions => ['bu_code = ? 
				AND position_name = ?', house.bu_code, 
				"Awake Overnight"]) +
			HouseStaff.find(:all, :conditions => ['bu_code = ? 
				AND position_name = ?', house.bu_code, 
				"Sleep Overnight"])
table_draw pdf, overnights, "Overnight Staff"
	
pdf.move_down(15)

pdf.text "Relief Staff", :style => :bold, :size => 12
reliefs = HouseStaff.find(:all, :conditions => ['bu_code = ? 
				AND position_name = ?', house.bu_code, 
				"Relief Manager"])
table_draw pdf, reliefs, "Relief Staff"

pdf.move_down(15)

pdf.text "PSS", :style => :bold, :size => 12
pss = HouseStaff.find(:all, :conditions => ['bu_code = ? 
			AND position_name = ?', house.bu_code, "PSS"])
table_draw pdf, pss, "PSS"

pdf.move_down(15)

pdf.text "Brief Overview of House: ", :style => :bold, :size => 12
pdf.text "#{house.overview}"

pdf.move_down(15)

pdf.text "Ratio: ", :style => :bold, :size => 12
pdf.text "#{house.ratio}"

pdf.move_down(15)

pdf.text "Trainings Needed: ", :style => :bold, :size => 12
pdf.text "#{house.trainings_needed}"

pdf.move_down(15)

pdf.text "Medication Times: ", :style => :bold, :size => 12
pdf.text "#{house.medication_times}"

pdf.move_down(15)

pdf.text "Relief Pay: ", :style => :bold, :size => 12
pdf.text "#{house.relief_pay}"

pdf.move_down(15)

pdf.text "Waivers: ", :style => :bold, :size => 12
pdf.text "#{house.waivers}"

pdf.move_down(15)

pdf.text "Keys: ", :style => :bold, :size => 12
pdf.text "#{house.keys}"

pdf.move_down(15)

pdf.text "Schedule Info: ", :style => :bold, :size => 12
pdf.text "#{house.schedule_info}"

pdf.move_down(15)

pdf.text "Behavior Plans: ", :style => :bold, :size => 12
pdf.text "#{house.behavior_plans}"

	# when one house is finished reporting, this makes it 
	# start a new page on the pdf for the next house
	if i != @houses.length - 1
		pdf.start_new_page
	end
end