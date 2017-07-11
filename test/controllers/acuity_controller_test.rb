require 'test_helper'

class AcuityControllerTest < ActionDispatch::IntegrationTest
  test "should get test" do
    get acuity_test_url
    assert_response :success
  end

end
