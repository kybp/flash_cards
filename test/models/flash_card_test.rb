require 'test_helper'

class FlashCardTest < TestCase
  def setup
    @valid_question   = 'question'
    @valid_answer     = 'answer'
    @valid_flash_card = flash_cards(:flash_card_one)
    @valid_user       = users(:user_one)
    @valid_user_two   = users(:user_two)
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

  test '#answer! raises ArgumentError on response quality > 5' do
    assert_raises(ArgumentError) do
      @valid_flash_card.answer!(6)
    end
  end

  test '#answer! accepts response qualities in 1..5' do
    (1..5).each do |i|
      assert_nothing_raised do
        @valid_flash_card.answer!(i)
      end
    end
  end
end
