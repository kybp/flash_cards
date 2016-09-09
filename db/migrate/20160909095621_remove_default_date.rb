class RemoveDefaultDate < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:flash_cards, :next_review_date, nil)
  end
end
