class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.integer :upload_id
      t.string :title
      t.string :project
      t.string :contact_givenname
      t.string :contact_surname
      t.string :contact_email
      t.text   :abstract
      t.string :keywords
      t.string :rights
      t.string :license
      t.timestamps
    end
    add_index :metadata, :upload_id
  end
end
