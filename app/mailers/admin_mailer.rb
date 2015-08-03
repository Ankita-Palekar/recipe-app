class AdminMailer < ActionMailer::Base
	default from: 'ankita@vacationlabs.com'										#'admin@foodholic.'
	def recipe_created_email(email)
		mail(to: email, subject: 'Recipe created by user')
	end
end