// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require turbolinks
//= require_tree .

jQuery(document).ready(function($){
	var setCountdown;
	setCountdown = function(length) {
		var countdown = jQuery('#countdown');
		var remaining = 140 - length;
		countdown.text(remaining)
		countdown.attr('class', (remaining >= 0) ? 'valid' : 'invalid')
	}
	
	var content = jQuery('#micropost_content')
	setCountdown(content.val().length)
	content.on('input propertychange', function() {
		setCountdown(content.val().length)
	})
});