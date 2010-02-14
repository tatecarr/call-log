@houses.each_with_index do |house, i|
	pdf.text "BU Code: #{house.bu_code}", :size => 16, :style => :bold, :spacing => 4
	pdf.text "Name: #{house.name}", :spacing => 16
	
	unless house.house_staffs.empty?
		staffs = house.house_staffs.map do |staff|
		  [
		    staff.id,
		    staff.position_name
		  ]
		end
	
		pdf.table staffs, :border_style => :grid,
		  :row_colors => ["FFFFFF","DDDDDD"],
		  :headers => ["Id", "Position"],
		  :align => { 0 => :left, 1 => :right }
	end
	
	if i != @houses.length - 1
		pdf.start_new_page
	end
end