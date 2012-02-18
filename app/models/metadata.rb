class Metadata < ActiveRecord::Base
  belongs_to :upload
  
  validates_presence_of :title, :contact_givenname, :contact_surname, :contact_email, :rights, :license
end
