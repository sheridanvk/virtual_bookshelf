class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :add_goodreads]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        # if @user.goodreads_id
        #   build_bookshelf
        # end
        test_redirect_url = get_oauth_url
        puts "can I see the request token here create? #{@request_token}"
        format.html { redirect_to test_redirect_url, id: @user.id}
        # format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_goodreads
    @request_token = session[:request_token]
    puts "can I see the request token here add_goodreads? #{@request_token}"
    puts "can I see the request token here add_goodreads session version? #{session[:request_token]}"

    access_token = @request_token.get_access_token
    if has_bookshelf
      redirect_to @user
    elsif !access_token
      format.html { redirect_to get_oauth_url, id: @user.id}
    else
      @user.update(oauth_token: access_token)
      goodreads_client_oauth = Goodreads.new(oauth_token: access_token)
      @user.goodreads_id = goodreads_client_oauth.user_id
      build_bookshelf
      redirect_to @user
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :password, :email)
    end

    def get_oauth_url
      callback_url = "#{add_goodreads_user_url(@user)}"
      @request_token = OAuth::Consumer.new(ENV['GOODREADS_API_KEY'],ENV['GOODREADS_API_SECRET'],
        site: "http://www.goodreads.com").get_request_token
      puts "Request token created: #{@request_token}"
      session[:request_token] = @request_token
      puts "Request token session version: #{session[:request_token]}"
      oauth_url = @request_token.authorize_url(:oauth_callback => callback_url)
    end

    def has_bookshelf
      # Return true if the user has at least one book already
      (Book.where user_id: @user.id).count > 0
    end

    def build_bookshelf
      page_number = 1

      loop do
        @goodreads_client = Goodreads::Client.new(api_key: ENV['GOODREADS_API_KEY'], api_secret: ENV['GOODREADS_API_SECRET'])
        bookshelf = @goodreads_client.shelf(@user.goodreads_id, 'read', {page:page_number})

        bookshelf.books.each do |item|
          @user.books.create(title: item.fetch("book").fetch("title"),
          isbn: item.fetch("book").fetch("isbn"),
          author: item.fetch("book").fetch("authors").fetch("author").fetch("name"))
        end

        break if bookshelf.total <= bookshelf.end
        page_number += 1
      end
    end
end
