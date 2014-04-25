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
})
