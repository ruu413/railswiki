class CreateUploadfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :uploadfiles do |t|
      t.integer :page_id
      t.string  :file_name
      t.string  :file_content_type
      #t.binary  :file
      t.string  :file_path
      
      t.timestamps
    end
  end
end
