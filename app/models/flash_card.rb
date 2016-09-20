class FlashCard < ApplicationRecord
  validates :question, uniqueness: { scope: :user_id }, presence: true
  validates :answer, presence: true
  after_initialize :set_first_review_date
  belongs_to :user

  def set_first_review_date
    self.next_review_date ||= Date.today
  end

  def answer!(response_quality)
    self.repetitions += 1
    next_review_interval!
    self.next_review_date = Date.today.days_since(review_interval)
    next_easiness!(response_quality)

    if response_quality < 3
      self.repetitions     = 0
      self.review_interval = 1
    end

    if response_quality < 4
      self.next_review_date = Date.today
    end

    save!
  end

  def self.search(user:, term:)
    return [] if term == ''

    self.where(user: user)
        .where('question ilike ? or answer ilike ?',
               "%#{escape_wildcards(term)}%",
               "%#{escape_wildcards(term)}%")
  end

  private

  def self.escape_wildcards(term)
    term.gsub(/[%_]/) { |c| "\\#{c}" }
  end

  def next_review_interval!
    current_interval = review_interval

    if repetitions < 1
      raise(RuntimeError,
	    'Cannot calculate next review interval before any repetitions')
    elsif repetitions == 1
      self.review_interval = 6
    else
      self.review_interval = (last_review_interval * easiness).ceil
    end

    self.last_review_interval = current_interval
  end

  def next_easiness!(response_quality)
    unless response_quality.between?(0, 5)
      raise(ArgumentError,
	    "response_quality not in 0..5: #{response_quality}")
    end

    self.easiness = [1.1, easiness].max +
      (0.1 - (5 - response_quality) *
       (0.08 + (5 - response_quality) * 0.02))
  end
end
