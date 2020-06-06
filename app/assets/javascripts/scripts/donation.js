/* global $, stripe */

const Donations = {

  load: function() {
    console.log('Initialize Donation.js') // eslint-disable-line no-console

    Donations.$modal = $('.ui.donation.modal')
    Donations.$message = $('.ui.donation.modal .ui.message')
    Donations.$form = $('.ui.donation.modal .ui.form')
    Donations.$buttons = $('.ui.donation.modal .ui.approve.button')
    Donations.state = 'idle'
  
    Donations.$modal.modal({
      inverted: true,
      autofocus: false,
      onApprove: function($element) {
        Donations.submitForm($element)
        return false
      },
      onDeny: function(_$element) {
        if (Donations.$form.hasClass('loading')) {
          Donations.setState('idle')
          return false
        }
      },
      onHidden: function() {
        Donations.setState('idle')
      },
    })
  
    $('.ui.donation.button').click(function() {
      Donations.$modal.modal('show')
    })
  },

  submitForm: function($button) {
    Donations.setState('loading')
    $button.addClass('pink')

    $.get({
      url: Donations.$form.data('url'),
      data: {
        mode: $button.data('mode'),
        currency: Donations.$form.find('input[name="currency"]').val(),
        amount: Donations.$form.find('input[name="amount"]').val(),
      },
      dataType: 'json',
      success: function(result) {
        Donations.processServerResponse(result)
      },
      error: function(result, textStatus, errorThrown) {
        Donations.setState('error', errorThrown)
      },
    })
  },

  processServerResponse(result) {
    if (Donations.state != 'loading') {
      console.log('Ignoring canceled donation from server.') // eslint-disable-line no-console
      return
    }

    if (result.status == 'success') {
      Donations.setState('submitted')
      stripe.redirectToCheckout({
        sessionId: result.session_id,
      }).then(function (result) {
        Donations.setState('error', result.error.message)
      })
    } else {
      Donations.setState('error', result.message)
    }
  },

  setState(state, message) {
    Donations.state = state

    if (state == 'loading') {
      Donations.$message.addClass('hidden')
      Donations.$buttons.addClass('disabled').removeClass('pink')
      Donations.$form.addClass('loading')
    } else {
      Donations.$buttons.removeClass('disabled').addClass('pink')
      Donations.$form.removeClass('loading')
    }

    if (message) {
      Donations.$message.text(message).removeClass('hidden')
    }
  },

}

$(document).on('turbolinks:load', () => Donations.load())
