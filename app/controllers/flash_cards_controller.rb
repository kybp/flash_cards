class FlashCardsController < ApplicationController
  before_action :authenticate_user!

  def index
    cards = FlashCard.where(user: current_user)

    respond_to do |format|
      format.html {}
      format.json { render json: cards }
    end
  end

  def manage
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

  def show
    card = FlashCard.where(user: current_user, id: params[:id]).first

    if card.nil?
      head :not_found
    else
      render json: card
    end
  end

  def update
    card = FlashCard.where(user: current_user, id: params[:id]).first

    return head :not_found if card.nil?

    if card.update_attributes(flash_card_params)
      head :ok
    else
      head :unprocessable_entity
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
    flash_card = FlashCard.where(id: params[:id]).first
    return head :not_found if flash_card.nil?

    response_quality = params[:response_quality]
    return head :bad_request if response_quality.nil?

    begin
      flash_card.answer!(response_quality.to_i)
      head :ok
    rescue ArgumentError
      head :bad_request
    end
  end

  def search
    term = params[:term]

    if term.nil?
      head :bad_request
    else
      render json: FlashCard.search(user: current_user, term: term)
    end
  end

  private

  def flash_card_params
    params.require(:flash_card).permit(:question, :answer)
  end
end
