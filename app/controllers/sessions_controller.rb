class SessionsController < ApplicationController
  def new
    if (!current_user.nil?)
      redirect_to current_user
    end
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
      log_in user
      redirect_to user
    else
      # Create an error message.
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'

    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

  def check_goodreads_authentication
    # Make sure the request was authorised and we have an OAuth request token.
    # If not, return an error and have the user try again
    # TODO make this actually an error instead of sending user back to Goodreads
    if !(params[:authorize] && session[:request_token])
      respond_to do |format|
        format.html {redirect_to get_oauth_url}
      end

    else
      # Pull the request token back out of the session
      request_token = session[:request_token]
      access_token = request_token.get_access_token
      goodreads_client_oauth = Goodreads.new(oauth_token: access_token)
      goodreads_user_id = goodreads_client_oauth.user_id
      # Looks to see whether we already have an account for this Goodreads ID
      if @user = User.find_by(goodreads_id: goodreads_user_id)
        if !@user.name
          respond_to do |format|
            format.html {redirect_to edit_user_path(@user)}
          end
        else
          respond_to do |format|
            format.html {redirect_to @user}
          end
        end
      else
        @user = User.create(oauth_token: access_token, goodreads_id: goodreads_user_id)
        puts @user.name

        respond_to do |format|
          if @user.save
            log_in @user
            Bookshelf.new(@user).build_bookshelf
            format.html { redirect_to edit_user_path(@user)}
            # format.json { render :show, status: :created, location: @user }
          else
            format.html { render :new }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        end

      end
    end
  end

end
