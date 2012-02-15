class Upload < ActiveRecord::Base
  has_one :tree

  attr_accessible :email, :dwc, :dwc_cache
  validates_presence_of :email, :dwc

  mount_uploader :dwc, DarwinCoreUploader
  
  before_create :generate_token
  after_create :create_new_tree
  after_save :enqueue
  
  attr_reader   :darwin_core_data, :name_strings, :dwc_tree

  NAME_BATCH_SIZE = 10_000
  
  def self.perform(id)
    upload = self.find(id)
    upload.tree.status = 1
    upload.tree.save
    upload.import
  end
  
  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end
  
  def create_new_tree
    self.create_tree!(:status => 0)
  end

  def import
    begin
      read_tarball
      store_tree
      nested_sets
      activate_tree
      send_mail
    rescue RuntimeError => e
    end
  end

  def read_tarball
    dwc_extract       = DarwinCore.new(self.dwc.path)
    normalizer        = DarwinCore::ClassificationNormalizer.new(dwc_extract)
    @darwin_core_data = normalizer.normalize(:with_canonical_names => false)
    @dwc_tree         = normalizer.tree
    @name_strings     = normalizer.name_strings
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
    Node.transaction do
      build_tree(dwc_tree)
    end
  end

  def build_tree(root, parent_id = self.tree.root.id)
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
                                       #{self.tree.id}, #{parent_id}, #{rank_sql})")
      build_tree(root[taxon_id], node_id)
    end
  end
  
  def nested_sets
    Node.rebuild!
  end

  def activate_tree
    self.tree.status = 2
    self.tree.save
  end
  
  def send_mail
    Mailer.preview_email(self).deliver
  end

end
