class Photo < ActiveRecord::Base
  belongs_to :recipe

  attr_accessible :recipe_id, :avatar
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  # validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  # validates :recipe_id, :presence => true
  validates_attachment :avatar, :presence => true,
    :content_type => { :content_type => /\Aimage\/.*\Z/ }
end
