class MakeFlashCardQuestionUnique < ActiveRecord::Migration[5.0]
  def change
    add_index :flash_cards, :question, unique: true
  end
end
