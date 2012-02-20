class Upload < ActiveRecord::Base
  has_one :tree
  has_one :metadata

  attr_accessible :email, :dwc, :dwc_cache
  validates_presence_of :email, :dwc

  mount_uploader :dwc, DarwinCoreUploader
  
  before_create :generate_token
  after_create :create_new_tree
  after_create :create_new_metadata
  
  attr_reader   :darwin_core_data, :name_strings, :dwc_extract, :dwc_tree, :new_root, :tmp_file

  NAME_BATCH_SIZE = 10_000
  @queue = :dwc_importer
  
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
  
  def create_new_metadata
    meta = Metadata.new
    meta.upload = self
    meta.contact_email = self.email
    meta.save(:validate => false)
  end

  def import
    begin
      read_tarball
      update_metadata
      store_tree
      #TODO: build nested sets with speed
      #nested_sets
      activate_tree
      send_mail
    rescue RuntimeError => e
      self.tree.status = 99
      self.tree.save
      send_error_mail
    end
  end

  def read_tarball
    @dwc_extract      = DarwinCore.new(self.dwc.path)
    normalizer        = DarwinCore::ClassificationNormalizer.new(dwc_extract)
    @darwin_core_data = normalizer.normalize(:with_canonical_names => false)
    @dwc_tree         = normalizer.tree
    @name_strings     = normalizer.name_strings
  end
  
  def update_metadata
    if dwc_extract.respond_to?("eml")
      self.metadata.title = dwc_extract.eml.respond_to?("title") ? dwc_extract.eml.title : nil
      self.metadata.abstract = dwc_extract.eml.respond_to?("abstract") ? dwc_extract.eml.abstract : nil
      self.metadata.save(:validate => false)
    end
  end
  
  def create_new_root
    name = Name.find_or_create_by_name_string("tree_root")
    Node.create!(:parent_id => nil, :tree => self.tree, :name => name)
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

    @tmp_file = Tempfile.new('dwc', '/tmp')
    Node.transaction do
      #WARNING!!! Will not work if more than one worker, would otherwise need composite keys in db
      @node_id = create_new_root.id
      build_tree(dwc_tree)
      File.chmod(0644, tmp_file.path)
      #WARNING!!! Hack to accommodate OSX-specific bug in mysql2 gem
      local = (Rails.env == "production") ? "LOCAL" : ""
      Node.connection.execute "LOAD DATA #{local} INFILE '#{tmp_file.path}' INTO TABLE nodes FIELDS TERMINATED BY '\\t' LINES TERMINATED BY '\\n'"
    end
    tmp_file.close
    tmp_file.unlink
  end

  #TODO: accommodate lft and rgt for nested sets as well
  def build_tree(root, parent_id = self.tree.root.id)
    taxon_ids = root.keys
    taxon_ids.each do |taxon_id|

      @node_id += 1
      next unless taxon_id && darwin_core_data[taxon_id]

      parent_id ||= 'NULL'
      name       = Name.find_by_name_string(darwin_core_data[taxon_id].current_name)
      rank       = darwin_core_data[taxon_id].rank

      tmp_file << [@node_id, parent_id, self.tree.id, name.id, taxon_id, rank].join("\t") + "\n"
      
      build_tree(root[taxon_id], @node_id)
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
  
  def send_error_mail
    Mailer.error_email(self).deliver
  end

end
