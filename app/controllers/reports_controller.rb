class ReportsController < ApplicationController

  def index
    @houses = House.all
    @staff = Staff.all
  end

end