/* global $ */

const Billing = {

  load: function() {
    console.log('Initialize Billing.js') // eslint-disable-line no-console

    Billing.$modal = $('.ui.billing.modal')
    Billing.$message = $('.ui.billing.modal .ui.message')
    Billing.$form = $('.ui.billing.modal .ui.form')
    Billing.$buttons = $('.ui.billing.modal .ui.approve.button')
    Billing.state = 'idle'
  
    Billing.$modal.modal({
      inverted: true,
      autofocus: false,
      onApprove: function($element) {
        Billing.submitForm($element)
        return false
      },
      onDeny: function(_$element) {
        if (Billing.$form.hasClass('loading')) {
          Billing.setState('idle')
          return false
        }
      },
      onHidden: function() {
        Billing.setState('idle')
      },
    })
  
    $('.ui.billing.button').click(function() {
      Billing.$modal.modal('show')
    })
  },

  submitForm: function($button) {
    Billing.setState('loading')
    $button.addClass('pink')

    $.get({
      url: Billing.$form.data('url'),
      data: {
        email: Billing.$form.find('input[name="email"]').val(),
      },
      dataType: 'json',
      success: function(result) {
        Billing.setState('success', result.message)
      },
      error: function(result, textStatus, errorThrown) {
        Billing.setState('error', result.responseJSON.message || errorThrown)
      },
    })
  },

  setState(state, message) {
    Billing.state = state

    if (state == 'loading') {
      Billing.$message.addClass('hidden')
      Billing.$form.addClass('loading')
    } else {
      Billing.$form.removeClass('loading')
    }

    if (message) {
      Billing.$message.text(message).removeClass('hidden')
      Billing.$message.toggleClass('error', state == 'error')
      Billing.$message.toggleClass('success', state == 'success')
    }
  },

}

$(document).on('turbolinks:load', () => Billing.load())
