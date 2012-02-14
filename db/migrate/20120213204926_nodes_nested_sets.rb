class NodesNestedSets < ActiveRecord::Migration
  def up
    add_column :nodes, :lft, :integer
    add_column :nodes, :rgt, :integer
    add_column :nodes, :depth, :integer
  end

  def down
    remove_column :nodes, :lft
    remove_column :nodes, :rgt
    remove_column :nodes, :depth
  end
end
