# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

root = exports ? this

root.ready = ->
    books = document.getElementsByClassName('book')
    for book in books
      font_size_check(book)
    console.log "Finished"
    return

font_size_check = (element) ->
  text_div = element.getElementsByClassName("rotate")[0]
  console.log text_div.textContent + " width: " + element.offsetWidth + ", height: " + text_div.offsetHeight
  while element.offsetWidth - text_div.offsetHeight < 10
    console.log "old offsetHeight: " + text_div.offsetHeight
    # Adjust the font size proportionally to how much it's overflowed
    adjust_factor = element.offsetWidth/(text_div.offsetHeight+10)
    current_font_size = $("#" + element.id + " .title").css 'font-size'
    new_font_size = Math.floor(adjust_factor*30)+"px"
    console.log element.id
    $("#" + element.id + " .title").css 'font-size', new_font_size
    console.log "done, new offsetHeight: " + text_div.offsetHeight
  return


# $(document).ready(ready)
# $(document).on('page:load', ready)
