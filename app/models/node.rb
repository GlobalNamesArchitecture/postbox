class Node < ActiveRecord::Base
  belongs_to :tree
  belongs_to :name
end
