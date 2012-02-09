class DropDwcImporters < ActiveRecord::Migration
  def up
    drop_table :dwc_importers
  end

  def down
  end
end
