//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sass-official
//= require angular
//= require_tree .

$(document).on('ajax:success', function() {
  $(':text').val('')
})
