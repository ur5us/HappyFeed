ready = ->
  $('.full_content img').each ->
    target_image = this
    image_url = $(target_image).data('image-proxy-src')

    $.ajax image_url,
      cache: true,
      processData: false
      success: ->
        $(target_image).attr('src', image_url)
        $(target_image).removeClass('loading_image')

  # Keep Pre-Tags aligned with content width.
  $('pre').hide()
  $('pre').css('width', $('.full_content').css('width'))
  $('pre').show()

$(document).ready(ready)
$(document).on('page:load', ready)