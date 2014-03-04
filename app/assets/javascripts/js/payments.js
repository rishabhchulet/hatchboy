select_tab({
  'tabs_class': 'payments-tab',
  'panes_class': 'tab-pane',
  'goto': window.location.hash.substring(1)
});

function select_tab(config) {
  if (config.goto !== '') {
    var tabs = document.getElementsByClassName(config.tabs_class);
    var panes = document.getElementsByClassName(config.panes_class);
    var hash_tab = document.getElementById(config.goto);
    for (var i = 0; i < tabs.length; i++) {
      if (tabs[i] == hash_tab) {
        tabs[i].className = config.tabs_class+" active";
        panes[i].className = config.panes_class+" active";
      } else {
        tabs[i].className = config.tabs_class;
        panes[i].className = config.panes_class;
      }
    }
  }
}

$(document).ready(function() {
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
};