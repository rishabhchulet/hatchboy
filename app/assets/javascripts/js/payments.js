var Tabs = function() {
  this.init = function() {
    /* Automagically jump on good tab based on anchor; for page reloads or links */
    if(location.hash) {
      $('a[href=' + location.hash + ']').tab('show');
    }

    /* removing events from configuration links to make them clickable */
    $('a.payment-config').unbind('click');
  }
}

$(document).ready(function() {
  var tabs = new Tabs
  tabs.init()

  $('.payment .amount').on('keyup change', function(){
    var val = $(this).val();
    if (val != '0' && val != '') {
      checkRecipient($(this), true);
    } else {
      checkRecipient($(this), false);
    }
  });

  $('.payment .check').on('change', function(){
    checkRecipient($(this), $(this).prop("checked"));
  });

  $('form.payment').submit(function(e){
    $(this).find("input.check").not(':checked').each(function(){
      $(this).closest('tr').find('input').prop('disabled', true);
    });
  });
});

function checkRecipient(obj, to_check) {
  var line = obj.closest('tr');
  var checkbox = line.find(':checkbox');

  checkbox.prop("checked", to_check);
  if (to_check) {
    line.addClass('row_selected');
  } else {
    line.removeClass('row_selected');
  }
}
