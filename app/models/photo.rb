class Photo < ActiveRecord::Base
  belongs_to :recipe
  # attr_accessible :title, :body
end
