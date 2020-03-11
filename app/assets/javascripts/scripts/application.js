
$(document).on('turbolinks:load', function() {
  console.log("Initialize JavaScript")
  $('.ui.accordion').accordion()
  $('.ui.dropdown').dropdown()
  $('.ui.progress').progress()

  $('.message .close').on('click', function() {
    $(this).closest('.message').transition('fade')
  })
})
