class UserMailer < ActionMailer::Base
	default from: 'ankita@vacationlabs.com'										#'admin@foodholic.'

	def recipe_approval_email(email)
		mail(to: email, subject: 'Admin recipe approval mail')
	end
end