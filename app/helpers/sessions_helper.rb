module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Returns the current logged-in user (if any).
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user.
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  # Returns the class that should be used for the body, if that's been set in
  # the view
  def body_class
    content_for(:body_class) || ""
  end

  # Builds and returns the URL at which a user can get authorisation for Goodreads
  def get_oauth_url
    # Build the URL to which the user will be redirected after the request token is authenticated
    callback_url = "#{check_goodreads_authentication_session_url(session)}"
    @request_token = OAuth::Consumer.new(ENV['GOODREADS_API_KEY'],ENV['GOODREADS_API_SECRET'],
      site: "http://www.goodreads.com").get_request_token

    # Put the request token in the session for use later
    session[:request_token] = @request_token
    oauth_url = @request_token.authorize_url(:oauth_callback => callback_url)
  end

end
