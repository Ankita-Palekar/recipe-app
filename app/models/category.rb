class Category < ActiveRecord::Base
	has_many :recipes
	belongs_to :user
	validates :name, presence:true, uniqueness: true  
	validate :check_admin
	 
	def check_admin
		user = User.find_by_id(user_id)
		user.valid ? errors.add(:base, "user is not admin") if user.admin == 'f' :  errors.add(:base, "Invalid user")
	end
end
