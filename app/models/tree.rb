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
  
  def nuke
    Tree.connection.execute("DELETE FROM nodes WHERE tree_id = #{id}")
    destroy
  end
  
  def statistics
    genera = %w(genus gen. gen)
    species = %w(species sp. sp)
    statistics = {
      :total_nodes => nodes.count,
      :total_leaves => nodes.leaves.count,
      :unique_names => Name.count(:joins => "INNER JOIN nodes on nodes.name_id = names.id", :conditions => "nodes.tree_id = #{id}", :distinct => "names.name_string"),
      :max_depth => nodes.maximum("depth"),
      :genera => nodes.where("rank IN (?)", genera).count,
      :species => nodes.where("rank IN (?)", species).count
    }
  end
  
end
