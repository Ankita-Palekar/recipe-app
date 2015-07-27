class UserMailer < ActionMailer::Base
	default from: 'ankita@vacationlabs.com'										#'admin@foodholic.'

	def recipe_approval_email(email)
		mail(to: email, subject: 'Admin recipe approval mail')
	end

	def recipe_rejected_email(email)
		mail(to: email, subject: 'Admin recipe rejected mail')
	end
end