class AddTokenToUpload < ActiveRecord::Migration
  def up
    add_column :uploads, :token, :string
  end

  def down
    remove_column :uploads, :token
  end
end
