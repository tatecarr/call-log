class ReportsController < ApplicationController
  before_filter :login_required

  def index
    @houses = House.all
    @staff = Staff.all
  end

end