class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :email
      t.string :dwc

      t.timestamps
    end
  end
end
