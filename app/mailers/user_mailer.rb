class UserMailer < ActionMailer::Base
	default from: 'ankita@vacationlabs.com'										#'admin@foodholic.'

	def recipe_approval_email(email, user, recipe)
		puts "inside recipe_approve"
		@recipe = recipe
		@user = user
		mail(to: email, subject: ' Admin approved your recipe ' + @recipe.name)
	end

	def recipe_rejected_email(email, user, recipe)
		puts "inside recipe reject"
		@recipe = recipe
		@user = user
		mail(to: email, subject: 'Admin rejected your recipe ' + @recipe.name)
	end
end