class AdminMailer < ActionMailer::Base
	default from: 'ankita@vacationlabs.com'										#'admin@foodholic.'
	def recipe_created_email(user)
		mail(to: email, subject: 'Recipe created by user')
	end
end