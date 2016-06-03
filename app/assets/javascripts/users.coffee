# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.ready = ->
  books = document.getElementsByClassName('book')
  for book in books
    font_size_check(book)
  return

font_size_check = (element) ->
  text_div = element.getElementsByClassName("spine_text")[0]

  # Return the correct width of the div (as we need to look at the height of the
  # div for the rotated elements)
  text_div_width = get_div_width(text_div)

  while element.offsetWidth - text_div_width < 5
    # Adjust the font size proportionally to how much it's overflowed
    adjust_factor = element.offsetWidth/(text_div_width)
    current_font_size = ($("#" + element.id + " .spine_text").css 'font-size').replace /px/, ""
    new_font_size = Math.floor(adjust_factor*parseInt(current_font_size,10))

    $("#" + element.id + " .spine_text").css 'font-size', (new_font_size+"px")

    text_div_width = get_div_width(text_div)
    break unless element.offsetWidth - text_div_width < 0
  return

get_div_width = (element) ->
  # Determine whether it's the height or the width of the dimension that needs
  # to be optimised (which is based on the text orientation)
  if (rotate_div = element.getElementsByClassName("rotate")[0])?
    text_div_width = rotate_div.offsetHeight
  else if (standard_div = element.getElementsByClassName("standard")[0])?
    text_div_width = standard_div.offsetWidth
  return text_div_width
