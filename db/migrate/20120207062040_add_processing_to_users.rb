class AddProcessingToUsers < ActiveRecord::Migration
  def change
    add_column :uploads, :dwc_processing, :boolean
  end
end
