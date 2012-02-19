class Metadata < ActiveRecord::Base
  belongs_to :upload
  after_initialize :init
  
  validates_presence_of :title, :contact_givenname, :contact_surname, :contact_email, :rights, :license

  def init
    self.license ||= "cc-0"
  end
end
