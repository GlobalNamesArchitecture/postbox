class Upload < ActiveRecord::Base

  attr_accessible :email, :dwc, :dwc_cache
  validates_presence_of :email

  mount_uploader :dwc, DarwinCoreUploader
  after_save :enqueue
  
  attr_reader   :darwin_core_data, :name_strings, :tree, :dwc_tree

  NAME_BATCH_SIZE = 10_000
  
  def self.perform(id)
    upload = self.find(id)
    upload.import
  end

  def import
    begin
      read_tarball
      create_tree
      store_tree
      activate_tree
    rescue RuntimeError => e
    end
  end

  def read_tarball
    dwc_extract       = DarwinCore.new(self.dwc.path)
    normalizer        = DarwinCore::ClassificationNormalizer.new(dwc_extract)
    @darwin_core_data = normalizer.normalize
    @dwc_tree         = normalizer.tree
    @name_strings     = normalizer.name_strings
  end
  
  def create_tree
    tree = Tree.new
    tree.save
    @tree = tree
    self.update_column :dwc_processing, 1
  end

  def store_tree
    count = 0
    name_strings.in_groups_of(NAME_BATCH_SIZE).each do |group|
      count += NAME_BATCH_SIZE
      group = group.compact.collect do |name_string|
        Name.connection.quote(name_string).force_encoding('utf-8')
      end.join('), (')

      Name.transaction do
        Name.connection.execute "INSERT IGNORE INTO names (name_string) VALUES (#{group})"
      end
    end
    @nodes_count = 0
    build_tree(dwc_tree)
  end

  def build_tree(root, parent_id = tree.root.id)
    taxon_ids = root.keys
    taxon_ids.each do |taxon_id|

      @nodes_count += 1
      next unless taxon_id && darwin_core_data[taxon_id]

      local_id_sql   = Name.connection.quote(taxon_id).force_encoding('utf-8')
      name_sql       = Name.connection.quote(darwin_core_data[taxon_id].current_name).force_encoding('utf-8')
      rank_sql       = Node.connection.quote(darwin_core_data[taxon_id].rank).force_encoding('utf-8')
      parent_id ||= 'NULL'

      node_id = Node.connection.insert("INSERT IGNORE INTO nodes (local_id, name_id, tree_id, parent_id, rank) \
                    VALUES (#{local_id_sql}, (SELECT id FROM names WHERE name_string = #{name_sql} LIMIT 1), \
                                       #{tree.id}, #{parent_id}, #{rank_sql})")
      build_tree(root[taxon_id], node_id)
    end
  end

  def activate_tree
    self.update_column :dwc_processing, 0
    self.update_column :tree_id, tree.id
    Mailer.preview_email(self).deliver
  end

end
