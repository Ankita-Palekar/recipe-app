class User < ActiveRecord::Base
	has_many :recipes , :dependent => :destroy
	has_many :ingredient, :dependent => :destroy
	has_many :ratings
  attr_accessible :email, :password, :password_confirmation, :is_admin, :name
  has_secure_password


	EMAIL_REGEX	=	/([A-Z]|[a-z]|[0-9])\w+(.)*@([a-z]|[A-Z]|[0-9])\w+(.)([a-z]|[A-z]|[0-9])+/
  validates :email, :presence	=>	true, :uniqueness	=>	true,	:format	=>	EMAIL_REGEX
  validates :password, :length => {:in => 8..20, :message => "Password should be between characters 8 to 20 "}
  validates :name, :presence => true
  
  def send_email_notification_for_recipes(function_name:)
    UserMailer.send function_name, email
    # UserMailer.recipe_approval_email(email).deliver
  end

  # def send_email_notification_recipe_rejected
  #   # UserMailer.recipe_rejected_email(email).deliver
  # end

  def self.authenticate(email:, password:)
    user = User.find_by_email(email)
    user.authenticate(password)
  end  

  def create_user(params_list:)
      
  end
end
