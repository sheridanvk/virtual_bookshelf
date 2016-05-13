# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.ready = ->
    books = document.getElementsByClassName('book')
    for book in books
      font_size_check(book)
    console.log "Finished test"
    return

font_size_check = (element) ->
  text_div = element.getElementsByClassName("spine_text")[0]

  if (rotate_div = text_div.getElementsByClassName("rotate")[0])?
    text_div_width = rotate_div.offsetHeight
  else if (standard_div = text_div.getElementsByClassName("standard")[0])?
    text_div_width = standard_div.getElementsByClassName("title")[0].offsetWidth

  console.log text_div.textContent
  console.log "inner width " + $(text_div).innerWidth() + ", scroll width" + text_div.scrollWidth
  console.log "text width " + text_div_width
  console.log "element width " + element.offsetWidth

  if element.offsetWidth - text_div_width < 10
    # Adjust the font size proportionally to how much it's overflowed
    adjust_factor = element.offsetWidth/(text_div_width+20)
    current_font_size = $("#" + element.id + " .title").css 'font-size'
    new_font_size = Math.floor(adjust_factor*30)
    console.log "new font size " + new_font_size + "px"
    $("#" + element.id + " .title").css 'font-size', (new_font_size+"px")

    if new_font_size <= 20
      $("#" + element.id + " .author").css 'font-size', (new_font_size-2)+"px"

  return


# $(document).ready(ready)
# $(document).on('page:load', ready)
