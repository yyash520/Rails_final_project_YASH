class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # This disables auto-login after sign-up
  def sign_up(resource_name, resource)
    # Do nothing
  end

  # Optional: redirect to login page after sign-up
  def after_sign_up_path_for(resource)
    new_session_path(resource_name) # Sends user to login
  end
end
