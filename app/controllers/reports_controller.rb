class ReportsController < ApplicationController
  # make sure the person is logged in
  before_filter :login_required

  # the only page in the reports section. Print all the reports from here
  def index
    @houses = House.all.sort_by(&:name)
    @staff = Staff.all
  end

end