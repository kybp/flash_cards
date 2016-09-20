require 'test_helper'

class FlashCardsControllerTest < ControllerTestCase 
  include Devise::Test::ControllerHelpers

  PAGE_LIMIT = 25

  def setup
    @user       = users(:user_one)
    @flash_card = flash_cards(:flash_card_one)
    @user_cards = "FlashCard.where(user_id: #{@user.id}).count"
    @invalid_id = 1
    @user_with_no_cards = users(:user_with_no_cards)

    @saved_flash_card = {
      question: @flash_card.question,
      answer:   @flash_card.answer
    }

    @unsaved_flash_card = {
      question: "123#{@flash_card.question}",
      answer:   @flash_card.answer
    }
  end

  test 'getting index for authenticated users returns 200 OK' do
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
    assert_difference(@user_cards) do
      post :create, params: { flash_card: @unsaved_flash_card }
    end
  end

  test 'posting duplicate flash card returns 422 unprocessable entity' do
    sign_in @user
    post :create, params: { flash_card: @saved_flash_card }
    assert_response :unprocessable_entity
  end

  test 'getting manage for authenticated user returns 200 OK' do
    sign_in @user
    get :manage
    assert_response :ok
  end

  test 'getting manage redirects unauthenticated users to sign in page' do
    get :manage
    assert_redirected_to new_user_session_path
  end

  test 'deleting valid flash card returns 200 OK' do
    sign_in @user
    delete :destroy, params: { id: @flash_card.id }
    assert_response :ok
  end

  test 'deleting nonexistent flash card returns 404 not found' do
    sign_in @user
    delete :destroy, params: { id: @invalid_id }
    assert_response :not_found
  end

  test 'deleting flash card removes it from the database' do
    sign_in @user
    assert_difference(@user_cards, -1) do
      delete :destroy, params: { id: @flash_card.id }
    end
  end

  test 'putting flash card updates field' do
    sign_in @user
    new_question = "123#{@flash_card.question}"
    flash_card   = @saved_flash_card.merge({ question: new_question })
    put :update, params: { id: @flash_card.id, flash_card: flash_card }
    @flash_card.reload
    assert_equal new_question, @flash_card.question
  end

  test 'putting nonexistent flash card returns 404 not found' do
    sign_in @user
    put :update, params: { id: @invalid_id, flash_card: @unsaved_flash_card }
    assert_response :not_found
  end

  test 'putting invalid flash card returns 422 unprocessable entity' do
    sign_in @user
    flash_card = @saved_flash_card.merge({ question: '' })
    put :update, params: { id: @flash_card.id, flash_card: flash_card }
    assert_response :unprocessable_entity
  end

  test 'getting show for valid user returns 200 OK' do
    sign_in @user
    get :show, params: { id: @flash_card.id }
    assert_response :ok
  end

  test 'getting show for nonexistent user returns 404 not found' do
    sign_in @user
    get :show, params: { id: @invalid_id }
    assert_response :not_found
  end

  test 'getting search with term returns 200 OK' do
    sign_in @user
    get :search, params: { term: 'foo' }
    assert_response :ok
  end

  test 'getting search without term returns 400 bad request' do
    sign_in @user
    get :search
    assert_response :bad_request
  end

  test 'getting search returns matching cards' do
    sign_in @user
    get :search, params: { term: @flash_card.question }
    assert_equal 1, JSON.parse(@response.body).length
  end

  test 'getting search returns only cards belonging to the current user' do
    sign_in @user_with_no_cards
    get :search, params: { term: @flash_card.question }
    assert_equal 0, JSON.parse(@response.body).length
  end
end
