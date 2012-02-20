class Tree < ActiveRecord::Base
  belongs_to :upload
  has_many :nodes
  
  @queue = :dwc_nuke

  def self.perform(id)
    tree = self.find(id)
    if tree.status != 3
      tree.nuke
    end
  end

  def root
    Node.where(:tree_id => self.id).where(:parent_id => nil).limit(1)[0]
  end

  def children_of(parent_id)
    if parent_id && Node.exists?(parent_id)
      nodes.find(parent_id).children
    else
      [self.root]
    end
  end
  
  def nuke
    self.upload.destroy
    Tree.connection.execute("DELETE FROM nodes WHERE tree_id = #{id}")
    destroy
  end
  
  def statistics
    genera = %w(genus gen. gen)
    species = %w(species sp. sp)
    statistics = {
      :total_nodes => nodes.count-1,
#      :total_leaves => nodes.leaves.count-1,
      :unique_names => Name.count(:joins => "INNER JOIN nodes on nodes.name_id = names.id", :conditions => "nodes.tree_id = #{id}", :distinct => "names.name_string")-1,
#      :max_depth => nodes.maximum("depth"),
      :genera => nodes.where("rank IN (?)", genera).count,
      :species => nodes.where("rank IN (?)", species).count
    }
  end
  
end
