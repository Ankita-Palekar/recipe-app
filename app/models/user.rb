class User < ActiveRecord::Base
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :avatar
	has_many :recipes , foreign_key: "creator_id", class_name: "Recipe", :dependent => :destroy
	has_many :ingredients, foreign_key: "creator_id", class_name: "Ingredient", :dependent => :destroy
	has_many :ratings, foreign_key: "rater_id", class_name: "Rating", :dependent => :destroy
  attr_accessible :email, :password, :password_confirmation, :is_admin, :name
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "200x200>", :big => "1000x1000>"}, :default_url => "/images/avatar-missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  # has_secure_password
  ROLES = %w(admin user) 
  validates :name, :presence => true
  devise :database_authenticatable, :registerable, :recoverable
  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  def user_notify_email(function_name:)
    # UserMailer.send(function_name, self.email).deliver
    UserMailer.delay.send(function_name, self.email) #for delayed jobs
  end

  def admin_notify_email(function_name:)
    # AdminMailer.send(function_name, self.email).deliver
    AdminMailer.delay.send(function_name, self.email) #for delayed jobs
  end
  
  def self.get_admins
    User.where(:is_admin=>true)
  end
 
  def user_recipe_details
    Recipe.list_recipes(list_type: 'order_by_date', status: 'approved', current_user:nil, other_user: self)   
  end

  def is_admin?
    self.is_admin
  end

  def is?(requested_role)
    self.role == requested_role.to_s
  end

  def self.from_omniauth_google(access_token)
      data = access_token.info
      user = User.where(:email => data["email"]).first
      #Uncomment the section below if you want users to be created if they don't exist
      unless user
        user = User.create(name: data["name"],
           email: data["email"],
           password: Devise.friendly_token[0,20]
        )
      end
      user
  end
end
