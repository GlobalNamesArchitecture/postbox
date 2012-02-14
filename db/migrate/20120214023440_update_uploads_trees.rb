class UpdateUploadsTrees < ActiveRecord::Migration
  def up
    remove_column :uploads, :tree_id
    remove_column :uploads, :dwc_processing
    add_column :trees, :upload_id, :integer
    add_column :trees, :status, :integer
  end

  def down
    add_column :uploads, :tree_id, :integer
    add_column :uploads, :dwc_processing, :integer
    remove_column :trees, :upload_id
    remove_column :trees, :status
  end
end
