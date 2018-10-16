$.reports =
  options:
    with_date_filter: false
    selectors:
      form: '#report-filter-form'

  form: null
  init:(options) ->
    @options = $.extend(@options, options || {})
    @form = $(@options.selectors.form)
    @init_handlers()

  init_handlers: ->
    if @options.with_date_filter
      @init_date_handlers()

  init_date_handlers: ->
    self = @
    @form.find('select[name="date"]').change((e)->
      self.form.find('.filter-specific-date').toggle(@value == 'specific', ->)
      self.form.find('.filter-period-date').toggle(@value == 'period', ->)
    ).change()

    @form.find('.input-append.date').datepicker(
      format: "yy-mm-dd",
      autoclose: true,
      todayHighlight: true
    )

    @form.submit((e) ->
      if ['specific', 'period'].indexOf(self.form.find('select[name="date"]').val()) == -1
        self.form.find('.input-append.date input').remove()
      true
    )

    true