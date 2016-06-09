class Bookshelf
  def initialize(user)
    @user = user
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
        book_isbn = item.fetch("book").fetch("isbn") || item.fetch("book").fetch("isbn")
        book_author = item.fetch("book").fetch("authors").fetch("author").fetch("name")

        book_pages_check = item.fetch("book").fetch("num_pages")

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
    font_colour = "#FCFBE3"
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
