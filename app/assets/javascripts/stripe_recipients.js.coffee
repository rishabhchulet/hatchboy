$ ->
  $("#credit-card input, #credit-card select").attr("disabled", false)

  $("form:has(#credit-card)").submit ->
    form = this
    $("#user_submit").attr("disabled", true)
    $("#credit-card input, #credit-card select").attr("name", "")
    $("#credit-card-errors").hide()

    if (!$("#credit-card").is(":visible"))
      $("#credit-card input, #credit-card select").attr("disabled", true)
      true
    
    card =
      number:   $("#credit_card_number").val(),
      expMonth: $("#_expiry_date_2i").val(),
      expYear:  $("#_expiry_date_1i").val(),
      cvc:      $("#cvv").val()

    Stripe.createToken card, (status, response) ->
      if (status == 200)
        $("#stripe_recipient_last_4_digits").val(response.card.last4)
        $("#stripe_recipient_stripe_token").val(response.id)
        form.submit()
      else
        $("#stripe-error-message").text(response.error.message)
        $("#credit-card-errors").show()

    false