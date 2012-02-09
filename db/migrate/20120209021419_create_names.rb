class CreateNames < ActiveRecord::Migration
  def change
    create_table :names do |t|
      t.string :name_string, :null => false
      t.timestamps
    end
  end
end
