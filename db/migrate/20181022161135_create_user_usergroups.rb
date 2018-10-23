class CreateUserUsergroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_usergroups do |t|
      t.references :user, foreign_key: true
      t.references :usergroup, foreign_key: true

      t.timestamps
    end
  end
end
