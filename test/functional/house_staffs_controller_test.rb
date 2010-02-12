require 'test_helper'

class HouseStaffsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:house_staffs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create house_staff" do
    assert_difference('HouseStaff.count') do
      post :create, :house_staff => { }
    end

    assert_redirected_to house_staff_path(assigns(:house_staff))
  end

  test "should show house_staff" do
    get :show, :id => house_staffs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => house_staffs(:one).to_param
    assert_response :success
  end

  test "should update house_staff" do
    put :update, :id => house_staffs(:one).to_param, :house_staff => { }
    assert_redirected_to house_staff_path(assigns(:house_staff))
  end

  test "should destroy house_staff" do
    assert_difference('HouseStaff.count', -1) do
      delete :destroy, :id => house_staffs(:one).to_param
    end

    assert_redirected_to house_staffs_path
  end
end
