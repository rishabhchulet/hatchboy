!function($) {
  'use strict';

  $(function() {
    var listCheckboxesSelector = '.list-selectable-checkbox', list = $('.action-list'), alertTimeout = 4000, listCheckboxes, listCheckboxesLength;

    // Automatically close alerts if there was any present.
    if ($('.alert').length > 0) {
      setTimeout(function() { $('.alert').alert('close'); }, alertTimeout);
    }

    // Only process list-related JavaScript if there's a list!
    if (list.length > 0) {
      listCheckboxes = list.find(listCheckboxesSelector);
      listCheckboxesLength = listCheckboxes.length;
      
      // Confirm before deleting one item
      $('.list-row-action-delete-one').on('click', function(ev) {
        ev.preventDefault();
        
        $('.list-row-action-popover-delete-one:visible').find('.cancel').trigger('click')
        
        $(this).addClass('list-row-action-wrapper-link-active')
          .siblings('.list-row-action-popover-delete-one').first().show()
          .find('.cancel').on('click', function() {

            $(this).parents('.list-row-action-popover-delete-one').hide()
              .siblings('.list-row-action-delete-one').removeClass('list-row-action-wrapper-link-active');
          });
      });
    }
  })
}(window.jQuery);
