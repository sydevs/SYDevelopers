
$(document).on('turbolinks:load', function() {
  console.log("Initialize JavaScript")
  $('.ui.accordion').accordion()
  $('.ui.progress').progress()
  $('.ui.scrollspy.menu').visibility({ type: 'fixed', offset: 15 })

  $('.ui.scrollspy.menu a').click(function(event) {
    $('html, body').animate({ scrollTop: $(event.target.href).offset().top }, 500)
    event.preventDefault()
    event.stopPropagation()
  })

  $('section[id]').visibility({
    once: false,
    includeMargin: true,
    onUpdate: function(calculations) {
      if (calculations.topPassed || (calculations.topVisible && calculations.bottomVisible)) {
        $('.ui.scrollspy.menu a').removeClass('active')
        $(`.ui.scrollspy.menu a[href="#${this.id}"]`).addClass('active')
      }
    },
  })
})
