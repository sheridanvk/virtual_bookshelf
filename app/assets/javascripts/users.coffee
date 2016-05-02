# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
    books = document.getElementsByClassName('book')
    for book in books
      font_size_check(book)

    return

font_size_check = (element) ->
  text_div = element.getElementsByClassName("rotate")[0]
  if element.offsetWidth - text_div.offsetHeight < 10
    # Adjust the font size proportionally to how much it's overflowed
    adjust_factor = element.offsetWidth/(text_div.offsetHeight+50)
    new_font = Math.floor(adjust_factor*35)+"px"
    $("#" + element.id + " .title").css 'font-size', new_font
  return

$(document).ready(ready)
$(document).on('page:load', ready)
