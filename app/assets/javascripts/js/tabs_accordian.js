$(document).ready(function() {	
	//Accordians
	$('.panel-group').collapse({
		toggle: false
	})	

/***** Tabs *****/
	//Normal Tabs - Positions are controlled by CSS classes
  $('#navigation-tab a').click(function (e) {
		e.preventDefault();
		$(this).tab('show');
	});

  // show active tab on reload
  if (location.hash !== '') $('a[href="' + location.hash + '"]').tab('show');

  // remember the hash in the URL without jumping
  $('#navigation-tab a').on('shown.bs.tab', function(e) {
    if(history.pushState) {
      history.pushState(null, null, '#'+$(e.target).attr('href').substr(1));
    } else {
      location.hash = '#'+$(e.target).attr('href').substr(1);
    }
  });

})
