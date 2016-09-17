require 'test_helper'

class FlashCardsControllerTest < ControllerTestCase 
  include Devise::Test::ControllerHelpers

  def setup
    @user = users(:user_one)
  end

  test 'index returns successfully for signed in user' do
    sign_in @user
    get :index
    assert_response :success
  end

  test 'index redirects unauthenticated users to sign in page' do
    get :index
    assert_redirected_to new_user_session_path
  end
end
