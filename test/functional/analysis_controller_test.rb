require 'test_helper'

class AnalysisControllerTest < ActionController::TestCase
  test "should get view" do
    get :view
    assert_response :success
  end

end
