class User < ActiveRecord::Base
	has_many :recipes , :dependent => :destroy
	has_many :ingredient, :dependent => :destroy
	has_many :ratings

  attr_accessible :email, :password, :password_confirmation, :is_admin
  has_secure_password
	EMAIL_REGEX	=	/([A-Z]|[a-z]|[0-9])\w+(.)*@([a-z]|[A-Z]|[0-9])\w+(.)([a-z]|[A-z]|[0-9])+/
  validates :email, :presence	=>	true, :uniqueness	=>	true,	:format	=>	EMAIL_REGEX, on 
  validates :password, :length => {:in => 8..20}

  #list of admin related functions
  #
  def login
    #if admin set admin session true rest all display will be dependent upon this session
  end

  def send_email_notification_recipe_accepted
    #send mail to user saying recipe accepted
  end


end
