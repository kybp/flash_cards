class FlashCardsController < ApplicationController
  def index
    @flash_cards = FlashCard.where('next_review_date <= ?', Date.today)

    respond_to do |format|
      format.html {}
      format.json { render json: @flash_cards }
    end
  end

  def create
    flash_card = FlashCard.new(flash_card_params)
    flash_card.save
    redirect_to action: 'index'
  end

  skip_before_filter :verify_authenticity_token, only: [:answer]
  def answer
    flash_card = FlashCard.find(params[:id])
    if params.has_key? :response_quality
      flash_card.answer!(params[:response_quality])
    end
    head :no_content
  end

  private

  def flash_card_params
    params.require(:flash_card).permit(:question, :answer)
  end
end
