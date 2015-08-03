class User < ActiveRecord::Base
	has_many :recipes , foreign_key: "creator_id", class_name: "Recipe", :dependent => :destroy
	has_many :ingredients, foreign_key: "creator_id", class_name: "Ingredient", :dependent => :destroy
	has_many :ratings, foreign_key: "rater_id", class_name: "Rating", :dependent => :destroy
  attr_accessible :email, :password, :password_confirmation, :is_admin, :name
  has_secure_password


	EMAIL_REGEX	=	/([A-Z]|[a-z]|[0-9])\w+(.)*@([a-z]|[A-Z]|[0-9])\w+(.)([a-z]|[A-z]|[0-9])+/
  validates :email, :presence	=>	true, :uniqueness	=>	true,	:format	=>	EMAIL_REGEX
  validates :password, :length => {:minimum => 8, :message => 'password length should me more then 8 chars'}
  validates :name, :presence => true
  
  def user_notify_email(function_name:)
    UserMailer.send function_name, self.email
    # UserMailer.recipe_approval_email(email).deliver
  end

  def admin_notify_email(function_name:)
    AdminMailer.send function_name, self.email
  end
  
  def self.get_admins
    User.where(:is_admin=>true)
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

  def is_admin?
    self.is_admin
  end
end
