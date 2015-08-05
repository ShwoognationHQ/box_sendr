require 'test_helper'

class BoxLoginsControllerTest < ActionController::TestCase
  setup do
    @box_login = box_logins(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:box_logins)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create box_login" do
    assert_difference('BoxLogin.count') do
      post :create, box_login: { details: @box_login.details, name: @box_login.name }
    end

    assert_redirected_to box_login_path(assigns(:box_login))
  end

  test "should show box_login" do
    get :show, id: @box_login
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @box_login
    assert_response :success
  end

  test "should update box_login" do
    patch :update, id: @box_login, box_login: { details: @box_login.details, name: @box_login.name }
    assert_redirected_to box_login_path(assigns(:box_login))
  end

  test "should destroy box_login" do
    assert_difference('BoxLogin.count', -1) do
      delete :destroy, id: @box_login
    end

    assert_redirected_to box_logins_path
  end
end
