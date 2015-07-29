class User < ActiveRecord::Base
	has_many :recipes , :dependent => :destroy
	has_many :ingredient, :dependent => :destroy
	has_many :ratings
  attr_accessible :email, :password, :password_confirmation, :is_admin, :name
  has_secure_password


	EMAIL_REGEX	=	/([A-Z]|[a-z]|[0-9])\w+(.)*@([a-z]|[A-Z]|[0-9])\w+(.)([a-z]|[A-z]|[0-9])+/
  validates :email, :presence	=>	true, :uniqueness	=>	true,	:format	=>	EMAIL_REGEX
  validates :password, :length => {:minimum => 8, :message => 'password length should me more then 8 chars'}
  validates :name, :presence => true
  
  def send_email_notification_for_recipes(function_name:)
    UserMailer.send function_name, email
    # UserMailer.recipe_approval_email(email).deliver
  end
  
  def create_user(params_list:)
    create!(params_list)
    self
  end

  def self.authenticate(email:, password:)
    user = User.find_by_email(email)
    if user && BCrypt::Password.new(user.password_digest) == password 
      user 
    end
  end
end
