class Tree < ActiveRecord::Base
  has_many :nodes
  after_create :create_root_node

  def root
    @root ||= Node.where(:tree_id => self.id).where(:parent_id => nil).limit(1)[0]
  end
    
  def create_root_node
    name = Name.find_or_create_by_name_string("tree_root")
    @root = Node.create!(:parent_id => nil, :tree => self, :name => name)
  end
  
end
