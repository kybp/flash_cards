class FlashCardsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def next
    cards = FlashCard
      .where(user: current_user)
      .where('next_review_date <= ?', Date.today)
      .order(updated_at: :desc)
      .limit(1)
    respond_to do |format|
      format.json { render json: cards.empty? ? nil : cards[0] }
    end
  end

  def create
    flash_card = FlashCard.new(flash_card_params)
    flash_card.user_id = current_user.id
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
