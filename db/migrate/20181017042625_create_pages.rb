class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.string :parent, null: false
      t.string :title, null: false
      t.text :content, null: false
      t.integer :last_edit_user_id, null: false
      t.integer :editable_group_id
      t.integer :readable_group_id
      t.timestamps
    end
  end
end
