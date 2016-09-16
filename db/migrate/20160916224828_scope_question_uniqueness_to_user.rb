class ScopeQuestionUniquenessToUser < ActiveRecord::Migration[5.0]
  def change
    remove_index :flash_cards, :question
    add_index :flash_cards, [:question, :user_id], unique: true
  end
end
