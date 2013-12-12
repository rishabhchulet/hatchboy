this.add_reset_behavior = (object) -> 
  object.on "change.bs.fileinput", ->
    object.addClass("fileinput-changed")
    object.find(".remove-avatar-field").attr("disabled", true)
  object.on "clear.bs.fileinput", ->
    object.addClass("fileinput-changed")
    object.find(".remove-avatar-field").attr("disabled", false)
  object.on "reset.bs.fileinput", ->
    object.removeClass("fileinput-changed")
    object.find(".remove-avatar-field").attr("disabled", true)
  object.find('[data-reset="fileinput"]').on "click", ->
    object.fileinput("reset");
