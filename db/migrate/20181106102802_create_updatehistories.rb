class CreateUpdatehistories < ActiveRecord::Migration[5.2]
  def change
    create_table :updatehistories do |t|
      t.integer :page_id
      t.integer :user_id
      t.text :content
      t.datetime :update_time
      t.timestamps
    end
  end
end
