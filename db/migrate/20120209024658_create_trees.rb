class CreateTrees < ActiveRecord::Migration
  def change
    create_table :trees do |t|

      t.timestamps
    end
  end
end
