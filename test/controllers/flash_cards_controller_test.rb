require 'test_helper'

class FlashCardsControllerTest < ControllerTestCase 
  include Devise::Test::ControllerHelpers

  def setup
    @user       = users(:user_one)
    @flash_card = flash_cards(:flash_card_one)
    @unsaved_flash_card = {
      question: "123#{@flash_card.question}",
      answer:   @flash_card.answer
    }
    @invalid_flash_card = {
      question: @flash_card.question,
      answer:   @flash_card.answer
    }
  end

  test 'getting index for signed in user returns 200 OK' do
    sign_in @user
    get :index
    assert_response :success
  end

  test 'getting index redirects unauthenticated users to sign in page' do
    get :index
    assert_redirected_to new_user_session_path
  end

  test 'getting index returns JSON list of flash cards' do
    sign_in @user
    get 'index', format: :json
    returned_count = JSON.parse(@response.body).length
    expected_count = FlashCard.where(user: @user).count
    assert_equal expected_count, returned_count
  end

  test 'posting valid flash card returns 201 created' do
    sign_in @user
    post :create, params: { flash_card: @unsaved_flash_card }
    assert_response :created
  end

  test 'posting valid flash card saves it in database' do
    sign_in @user
    assert_difference("FlashCard.where(user_id: #{@user.id}).count") do
      post :create, params: { flash_card: @unsaved_flash_card }
    end
  end

  test 'posting invalid flash card returns 422 unprocessable entity' do
    sign_in @user
    post :create, params: { flash_card: @invalid_flash_card }
    assert_response :unprocessable_entity
  end
end
