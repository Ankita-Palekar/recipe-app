class AdminMailer < ActionMailer::Base
	default from: 'ankita@vacationlabs.com'										#'admin@foodholic.'
	def recipe_created_email(email, user, recipe)
		puts "inside admin mailer"
		@user = user
		@recipe = recipe
		mail(to: email, subject: @user.name + " has create  recipe " + @recipe.name)
	end
end