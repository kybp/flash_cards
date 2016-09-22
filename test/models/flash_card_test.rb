require 'test_helper'

class FlashCardTest < SupportTestCase
  def setup
    @valid_question   = 'question'
    @valid_answer     = 'answer'
    @valid_flash_card = flash_cards(:flash_card_one)
    @valid_user       = users(:user_one)
    @valid_user_two   = users(:user_two)
    @flash_card_two   = flash_cards(:flash_card_two)
    @user_with_no_cards = users(:user_with_no_cards)
  end

  test 'does not save flash card without question' do
    card = FlashCard.new(answer: @valid_answer, user: @valid_user)
    assert_not card.save, 'Saved flash card without question'
  end

  test 'does not save flash card without answer' do
    card = FlashCard.new(question: @valid_question, user: @valid_user)
    assert_not card.save, 'Saved flash card without answer'
  end

  test 'does not save flash card without user' do
    card = FlashCard.new(question: @valid_question, answer: @valid_answer)
    assert_not card.save, 'Saved flash card without user'
  end

  test 'does not allow duplicate questions for same user' do
    FlashCard.create!(question: @valid_question, answer: @valid_answer,
                      user: @valid_user)
    card = FlashCard.new(question: @valid_question, user: @valid_user,
                         answer: "123#{@valid_question}")
    assert_not card.save,
      'Saved flash card with duplicate question for same user'
  end

  test 'allows duplicate questions for different users' do
    FlashCard.create!(question: @valid_question, answer: @valid_answer,
                      user: @valid_user)
    card = FlashCard.new(question: @valid_question, answer: @valid_answer,
                         user: @valid_user_two)
    assert card.save,
      'Did not save flash card with duplicate question for different user'
  end

  test '#answer! raises ArgumentError on negative response quality' do
    assert_raises(ArgumentError) do
      @valid_flash_card.answer!(-1)
    end
  end

  test '#answer! accepts response qualities in 1..5' do
    (1..5).each do |i|
      assert_nothing_raised do
        @valid_flash_card.answer!(i)
      end
    end
  end

  test '#answer! accepts response qualities above 5' do
    assert_nothing_raised do
      @valid_flash_card.answer!(6)
    end
  end

  test '#search returns cards whose questions contain term' do
    term   = @valid_flash_card.question[-5, 3]
    result = FlashCard.search(user: @valid_user, term: term)
    assert_equal [@valid_flash_card], result
  end

  test '#search returns cards whose answers contain term' do
    term   = @valid_flash_card.answer[-5, 3]
    result = FlashCard.search(user: @valid_user, term: term)
    assert_equal [@valid_flash_card], result
  end

  test '#search only returns cards belonging to user' do
    term   = @valid_flash_card.answer[-5, 3]
    result = FlashCard.search(user: @user_with_no_cards, term: term)
    assert_equal [], result
  end

  test '#search returns no results if term is the empty string' do
    assert_equal [], FlashCard.search(user: @valid_user, term: '')
  end

  test '#search is case insensitive' do
    term = @valid_flash_card.question
    user = @valid_user
    upper_results = FlashCard.search(user: user, term: term.upcase)
    lower_results = FlashCard.search(user: user, term: term.downcase)
    assert_equal upper_results.length, lower_results.length
    upper_results.length.times do |i|
      assert_equal upper_results[i], lower_results[i]
    end
  end

  test '#search escapes SQL wildcards' do
    card = FlashCard.create! user: @valid_user, question: '%', answer: '_'
    assert_equal [card], FlashCard.search(user: @valid_user, term: '%')
    assert_equal [card], FlashCard.search(user: @valid_user, term: '_')
  end
end
