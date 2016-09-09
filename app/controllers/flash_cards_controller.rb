class FlashCardsController < ApplicationController
  def index
    @flash_cards = FlashCard.all
  end

  def new
  end

  def create
    @flash_card = FlashCard.new(flash_card_params)
    @flash_card.save
    redirect_to action: 'index'
  end

  private

  def flash_card_params
    params.require(:flash_card).permit(:question, :answer)
  end
end
