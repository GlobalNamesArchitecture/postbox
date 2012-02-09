class CreateDwcImporters < ActiveRecord::Migration
  def change
    create_table :dwc_importers do |t|

      t.timestamps
    end
  end
end
