class FlashCardsController < ApplicationController
  before_action :authenticate_user!
  PAGE_LIMIT = 25

  def index
    offset = (params[:page] || 0).to_i

    cards = FlashCard
        .where(user: current_user)
        .offset(offset * PAGE_LIMIT)
        .limit(PAGE_LIMIT)

    respond_to do |format|
      format.html {}
      format.json { render json: cards }
    end
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
    flash_card.user = current_user
    if flash_card.save
      render json: flash_card, status: :created
    else
      render json: flash_card.errors, status: :unprocessable_entity
    end
  end

  def destroy
    card = FlashCard.where(user: current_user, id: params[:id]).first

    if card.nil?
      head :not_found
    else
      card.destroy
      head :ok
    end
  end

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
