require 'test_helper'

class FlashCardsControllerTest < ControllerTestCase 
  include Devise::Test::ControllerHelpers

  PAGE_LIMIT = 25

  def setup
    @user       = users(:user_one)
    @flash_card = flash_cards(:flash_card_one)
    @user_cards = "FlashCard.where(user_id: #{@user.id}).count"

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
    assert_response :ok
  end

  test 'getting index redirects unauthenticated users to sign in page' do
    get :index
    assert_redirected_to new_user_session_path
  end

  test 'getting index returns JSON list of flash cards' do
    sign_in @user
    get 'index', format: :json
    actual_count   = JSON.parse(@response.body).length
    expected_count = FlashCard.where(user: @user).count
    assert_equal expected_count, actual_count
  end

  test "JSON index returns at most #{PAGE_LIMIT} flash cards" do
    (PAGE_LIMIT + 10).times do
      FlashCard.create!(
        question: SecureRandom.hex, answer: SecureRandom.hex, user: @user)
    end

    sign_in @user
    get 'index', format: :json
    assert_equal PAGE_LIMIT, JSON.parse(@response.body).length
  end

  test 'JSON index accepts page argument' do
    over_limit = 10

    (PAGE_LIMIT + over_limit).times do
      FlashCard.create!(
        question: SecureRandom.hex, answer: SecureRandom.hex, user: @user)
    end

    sign_in @user
    get 'index', format: :json, params: { page: 1 }
    actual_count   = JSON.parse(@response.body).length
    expected_count = FlashCard.count - PAGE_LIMIT
    assert_equal expected_count, actual_count
  end

  test 'posting valid flash card returns 201 created' do
    sign_in @user
    post :create, params: { flash_card: @unsaved_flash_card }
    assert_response :created
  end

  test 'posting valid flash card saves it in database' do
    sign_in @user
    assert_difference(@user_cards) do
      post :create, params: { flash_card: @unsaved_flash_card }
    end
  end

  test 'posting invalid flash card returns 422 unprocessable entity' do
    sign_in @user
    post :create, params: { flash_card: @invalid_flash_card }
    assert_response :unprocessable_entity
  end

  test 'deleting valid flash card returns 200 OK' do
    sign_in @user
    delete :destroy, params: { id: @flash_card.id }
    assert_response :ok
  end

  test 'deleting nonexistent flash card returns 404 not found' do
    bad_id = 1
    assert_nil FlashCard.where(id: bad_id).first

    sign_in @user
    delete :destroy, params: { id: bad_id }
    assert_response :not_found
  end

  test 'deleting flash card removes it from the database' do
    sign_in @user
    assert_difference(@user_cards, -1) do
      delete :destroy, params: { id: @flash_card.id }
    end
  end
end
