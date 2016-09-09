class CreateFlashCards < ActiveRecord::Migration[5.0]
  def change
    create_table :flash_cards do |t|
      t.string  :question,             null: false
      t.string  :answer,               null: false
      t.float   :easiness,             null: false, default: 2.5
      t.integer :repetitions,          null: false, default: 0
      t.integer :review_interval,      null: false, default: 1
      t.integer :last_review_interval, null: true
      t.date    :next_review_date,     null: false, default: Date.today

      t.timestamps
    end
  end
end
