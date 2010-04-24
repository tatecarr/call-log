class ReportsController < ApplicationController
  before_filter :login_required

  def index
    @houses = House.all.sort_by(&:name)
    @staff = Staff.all
  end

end