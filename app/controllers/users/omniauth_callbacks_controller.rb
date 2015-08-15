class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
   # You need to implement the method below in your model (e.g. app/models/user.rb)
   @user = User.from_omniauth_google(request.env["omniauth.auth"])

   if @user.persisted?
     flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
     sign_in_and_redirect @user, :event => :authentication
   else
     session["devise.google_data"] = request.env["omniauth.auth"]
     redirect_to new_user_registration_url
   end
   end

  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
