class Node < ActiveRecord::Base
  belongs_to :tree
  belongs_to :name
  
  acts_as_nested_set :scope => :tree_id
  
  delegate :name_string, :to => :name
  
  def child_count
    Node.select(:id).where(:parent_id => id).size
  end
end