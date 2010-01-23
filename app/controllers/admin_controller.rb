class AdminController < ApplicationController
  def index
    @import = Import.new
  end


  def import_csv
    @import = Import.new(params[:import])
    @import.save
    
    lines = parse_csv_file(@import.csv.path)
    
    # map the column names to the right attributes in the db
    @row_positions = Hash.new
    Staff.column_names.each do |attribute|
      lines[0].each_with_index do |csv_row, index|
        if attribute == csv_row
          @row_positions[attribute.to_sym] = index
        end
      end
    end

    lines.shift #comment this line out if your CSV file doesn't contain a header row
    
    Staff.delete_all
    
    if lines.size > 0
      @import.processed = lines.size
      lines.each do |line|
          add_person(line)
      end
      @import.destroy
      flash[:notice] = "CSV data processing was successful."
      redirect_to :action => "index"
    else
      flash[:error] = "CSV data processing failed."
      render :action => "show", :id => @import.id
    end
	end

  def show
    @import = Import.find(params[:id])
	end

  private

    def parse_csv_file(path_to_csv)
      lines = []

      #if not installed run, sudo gem install fastercsv
      #http://fastercsv.rubyforge.org/
      require 'fastercsv' 

      FasterCSV.foreach(path_to_csv) do |row|
        lines << row
      end
      lines
    end

  	def add_person(line)
      params = Hash.new
      params[:staff] = Hash.new
      params[:staff][:staff_id] = line[@row_positions[:staff_id]]
  		params[:staff][:first_name] = line[@row_positions[:first_name]]
      params[:staff][:last_name] = line[@row_positions[:last_name]]
      params[:staff][:nickname] = line[@row_positions[:nickname]]
      params[:staff][:address] = line[@row_positions[:address]]
      params[:staff][:city] = line[@row_positions[:city]]
      params[:staff][:state] = line[@row_positions[:state]]
      params[:staff][:zip] = line[@row_positions[:zip]]
      params[:staff][:gender] = line[@row_positions[:gender]]
      params[:staff][:doh] = line[@row_positions[:doh]]
      params[:staff][:cell_number] = line[@row_positions[:cell_number]]
      params[:staff][:home_number] = line[@row_positions[:home_number]]
      params[:staff][:agency_staff] = line[@row_positions[:agency_staff]]
      person = Staff.new(params[:staff])
      person.save
  	end
end
