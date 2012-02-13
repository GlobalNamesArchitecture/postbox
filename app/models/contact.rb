class Contact < ActiveRecord::Base
  attr_accessible :email, :name, :message
  validates_presence_of :email, :message
end
