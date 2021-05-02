class ApplicationController < ActionController::Base
    protect_from_forgery prepend: true

    def authenticate_user!
      unless current_user.nil?
        unless current_user.enabled?
          redirect_to destroy_admin_user_session_path
        end
      else
       redirect_to new_admin_user_session_path
     end
   end
  end