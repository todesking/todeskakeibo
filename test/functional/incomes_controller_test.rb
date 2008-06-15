require 'test_helper'

class IncomesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:incomes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_income
    assert_difference('Income.count') do
      post :create, :income => { }
    end

    assert_redirected_to income_path(assigns(:income))
  end

  def test_should_show_income
    get :show, :id => incomes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => incomes(:one).id
    assert_response :success
  end

  def test_should_update_income
    put :update, :id => incomes(:one).id, :income => { }
    assert_redirected_to income_path(assigns(:income))
  end

  def test_should_destroy_income
    assert_difference('Income.count', -1) do
      delete :destroy, :id => incomes(:one).id
    end

    assert_redirected_to incomes_path
  end
end
