class AddTreeToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :tree_id, :integer
  end
end
