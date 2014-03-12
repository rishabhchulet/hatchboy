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

var Tabs = function() {
  this.init = function() {
    /* Automagically jump on good tab based on anchor; for page reloads or links */
    if(location.hash) {
      console.log(1)
      $('a[href=' + location.hash + ']').tab('show');
    }

    /* Update hash based on tab, basically restores browser default behavior to
       fix bootstrap tabs */
    $(document.body).on("click", ".nav-tabs a", function(e) {
      console.log(2)
      location.hash = this.getAttribute("href");
    });

    /* on history back activate the tab of the location hash
       if exists or the default tab if no hash exists */
    $(window).on('popstate', function() {
      var anchor = location.hash || $(".nav-tabs li.active a").attr("href") || $(".nav-tabs a").first().attr("href");;
      $('a[href=' + anchor + ']').tab('show');
    });

  }
}
