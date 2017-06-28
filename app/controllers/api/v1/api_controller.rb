class Api::V1::BaseController < ApplicationController

  protect_from_forgery with: :null_session
  # We must disable the CSRF token and disable cookies (no set-cookies header in response). Remember that APIs on HTTP are stateless and a session is exactly the opposite of that.

  before_action :destroy_session

  def destroy_session
    request.session_options[:skip] = true
  end


end
