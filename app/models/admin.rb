class Admin < User
	def self.get_all_admins
		where(:is_admin=>true)
	end

end