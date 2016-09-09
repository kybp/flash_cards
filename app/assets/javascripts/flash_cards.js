const flashCardController =
['$http', '$scope', '$timeout', function($http, $scope, $timeout) {
  const SECONDS_PER_CARD = 10

  $http.get('/flash_cards.json')
    .then(function(response) {
      $scope.cards = response.data
    }, function(response) {
      alert('error fetching cards: ' + response.status)
    })

  $scope.beganReview = false
  $scope.doneReview  = false

  $scope.beginReview = function() {
    $scope.beganReview  = true
    $scope.currentIndex = 0
    $scope.secondsLeft  = SECONDS_PER_CARD
    let timeout

    $scope.onTimeout = function() {
      const cardsRemaining = $scope.currentIndex + 1 < $scope.cards.length
      --$scope.secondsLeft

      if (cardsRemaining && $scope.secondsLeft === 0) {
        ++$scope.currentIndex
        $scope.secondsLeft = SECONDS_PER_CARD
      }

      if (cardsRemaining) {
        timeout = $timeout($scope.onTimeout, 1000)
      } else {
        $timeout.cancel(timeout)
        $scope.doneReview = true
      }
    }

    timeout = $timeout($scope.onTimeout, 1000)
  }
}]

angular
  .module('flashCards', [])
  .controller('flashCardController', flashCardController)
