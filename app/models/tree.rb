class Tree < ActiveRecord::Base
  belongs_to :upload
  has_many :nodes

  after_create :create_root_node

  def root
    @root ||= Node.where(:tree_id => self.id).where(:parent_id => nil).limit(1)[0]
  end
    
  def create_root_node
    name = Name.find_or_create_by_name_string("tree_root")
    @root = Node.create!(:parent_id => nil, :tree => self, :name => name)
  end

  def children_of(parent_id)
    if parent_id && Node.exists?(parent_id)
      nodes.find(parent_id).children
    else
      [self.root]
    end
  end
  
  def statistics
    statistics = {
      :total => nodes.count,
      :leaves => nodes.leaves.count,
      :species => nodes.where(:rank => "species").count
    }
  end
  
end
