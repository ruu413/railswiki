class CreateEmojis < ActiveRecord::Migration[5.2]
  def change
    create_table :emojis do |t|
      t.string :name
      t.integer :user_id
      #t.binary :image
      t.string :file_name
      t.timestamps
    end
  end
end
