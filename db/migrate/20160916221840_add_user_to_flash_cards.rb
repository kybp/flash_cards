class AddUserToFlashCards < ActiveRecord::Migration[5.0]
  def change
    add_reference :flash_cards, :user, foreign_key: true
  end
end
