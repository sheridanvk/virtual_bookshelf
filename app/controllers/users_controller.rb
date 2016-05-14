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
        log_in @user
        puts "can I see the request token here create? #{@request_token}"
        format.html { redirect_to get_oauth_url, id: @user.id}
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
    if has_bookshelf
      redirect_to @user
    elsif !params[:authorize]
      respond_to do |format|
        format.html {redirect_to get_oauth_url}
      end
    else
      # Pull the request token out of the session
      @request_token = session[:request_token]
      access_token = @request_token.get_access_token

      @user.update(oauth_token: access_token)
      goodreads_client_oauth = Goodreads.new(oauth_token: access_token)
      @user.update(goodreads_id: goodreads_client_oauth.user_id)
      build_bookshelf
      redirect_to @user
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.friendly.find(params[:id].to_s.downcase)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :password, :email)
    end

    def get_oauth_url
      # Build the URL to which the user will be redirected after the request token is authenticated
      callback_url = "#{add_goodreads_user_url(@user)}"
      @request_token = OAuth::Consumer.new(ENV['GOODREADS_API_KEY'],ENV['GOODREADS_API_SECRET'],
        site: "http://www.goodreads.com").get_request_token

      # Put the request token in the session for use later
      session[:request_token] = @request_token
      oauth_url = @request_token.authorize_url(:oauth_callback => callback_url)
    end

    def has_bookshelf
      # Return true if the user has at least one book already
      (Book.where user_id: @user.id).count > 0
    end

    def build_bookshelf
      # Initialise page number, which we'll use to iterate through the Goodreads paginated shelf data
      page_number = 1

      loop do
        @goodreads_client = Goodreads::Client.new(api_key: ENV['GOODREADS_API_KEY'], api_secret: ENV['GOODREADS_API_SECRET'])
        bookshelf = @goodreads_client.shelf(@user.goodreads_id, 'read', {page:page_number})

        bookshelf.books.each do |item|
          # Fetch the title and split it into title and subtitle where relevant
          book_full_title = item.fetch("book").fetch("title").partition(/[:(]/)
          book_title = book_full_title[0].strip
          if book_full_title.length > 1
            # Remove any stray parens and whitespace from subtitle, which is stored in the third element of the title array
            book_subtitle = (book_full_title[2].gsub /[:)(]/, "").strip
          end
          book_isbn = item.fetch("book").fetch("isbn")
          book_author = item.fetch("book").fetch("authors").fetch("author").fetch("name")

          book_pages_check = item.fetch("book").fetch("num_pages")
          book_pages = book_pages_check.presence || "250"
          book_pages = book_pages.to_i

          book_spine_colour = set_book_colours[0]
          book_font_colour = set_book_colours[1]
          book_height = set_book_height
          book_width = set_book_width
          book_text_orientation = set_book_text_orientation(book_title)

          book = @user.books.create(title: book_title,
          isbn: book_isbn,
          author: book_author,
          spine_colour: book_spine_colour,
          font_colour: book_font_colour,
          height: book_height,
          width: book_width,
          page_count: book_pages,
          text_orientation: book_text_orientation)

          if book_subtitle
            book.update(subtitle: book_subtitle)
          end
        end

        break if bookshelf.total <= bookshelf.end
        page_number += 1
      end
    end

    def set_book_colours
    # purples  colours = ["#600060","#710071","#960096","#A60FA6","#810081"]
    colours = ["#B74E54","#683A85","#256A98","#85A13F","#CFBB23"]
      spine_colour = colours.sample

      # Create a Paleta object to get the complementary colours
    #  paleta_colour = Paleta::Color.new(:hex, spine_colour)
    #  font_colour = "#"+paleta_colour.complement!.hex
      font_colour = "#D0f616"
      book_colours = [spine_colour,font_colour]
    end

    def set_book_height
      heights = [450,460,470,480,490,500]
      book_height = heights.sample
    end

    def set_book_width
      widths = [100,110,120,130,140,150]
      book_width = widths.sample
    end

    def set_book_text_orientation(title)
      #TODO add rotated_title as a layout option
      if title.length <= 20 # ensuring that long titles don't get written horizontally.
        #TODO decide if I should also add a max word length on this option
        orientation = ["standard","rotated_all"]
      else
        orientation = ["rotated_all"]
      end
      text_orientation = orientation.sample
    end
end
