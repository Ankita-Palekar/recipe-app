class User < ActiveRecord::Base
	has_many :recipes , :dependent => :destroy
	has_many :ingredient, :dependent => :destroy
	has_many :ratings
	attr_protected :password_digest, :admin
  attr_accessible :email, :password, :password_confirmation, :is_admin
  has_secure_password


	EMAIL_REGEX	=	/([A-Z]|[a-z]|[0-9])\w+(.)*@([a-z]|[A-Z]|[0-9])\w+(.)([a-z]|[A-z]|[0-9])+/
  validates :email, :presence	=>	true, :uniqueness	=>	true,	:format	=>	EMAIL_REGEX
  validates :password, :length => {:in => 8..20, :message => "Password should be between characters 8 to 20 "}

  def send_email_notification_recipe_approved
    UserMailer.recipe_approval_email(email).deliver
  end
end
