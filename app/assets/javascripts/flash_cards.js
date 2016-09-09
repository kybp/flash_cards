const flashCardController = ['$http', '$scope', function($http, $scope) {
  $http.get('/flash_cards.json')
    .then(function(response) {
      $scope.cards = response.data
    }, function(response) {
      alert('error fetching cards: ' + response.status)
    })
}]

angular
  .module('flashCards', [])
  .controller('flashCardController', flashCardController)
