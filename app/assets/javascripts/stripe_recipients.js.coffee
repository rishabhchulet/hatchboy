$ ->
  stripe_recipient.setupForm()

stripe_recipient =
  setupForm: ->
    $("form:has(#credit-card)").submit ->
      form = this
      $("#credit-card input, #credit-card select").attr("name", "")
      $("#credit-card-errors").hide()
      $('#process-button').attr('disabled', true)

      Stripe.createToken stripe_recipient.getCardObj(), (status, response) ->
        if (status == 200)
          $("#stripe_recipient_last_4_digits").val(response.card.last4)
          $("#stripe_recipient_stripe_token").val(response.id)
          form.submit()
        else
          $("#stripe-error-message").text(response.error.message)
          $("#credit-card-errors").show()
          $('#process-button').attr('disabled', false)

      false

  getCardObj: ->
    card =
      number:   $("#credit_card_number").val(),
      expMonth: $("#_expiry_date_2i").val(),
      expYear:  $("#_expiry_date_1i").val(),
      cvc:      $("#cvv").val()