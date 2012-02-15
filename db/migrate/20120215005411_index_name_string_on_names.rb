class IndexNameStringOnNames < ActiveRecord::Migration
  def up
    add_index :names, :name_string, :unique => true
  end

  def down
    remove_index :names, :column => :name_string
  end
end
