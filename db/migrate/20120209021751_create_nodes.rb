class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.integer :parent_id
      t.integer :tree_id
      t.integer :name_id
      t.string :local_id
      t.string :rank
      t.timestamps
    end
    add_index :nodes, :parent_id
    add_index :nodes, :tree_id
  end
end
