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
      --$scope.secondsLeft

      if ($scope.secondsLeft <= 0) {
        ++$scope.currentIndex
        $scope.secondsLeft = SECONDS_PER_CARD
      }

      if ($scope.currentIndex < $scope.cards.length) {
        scheduleTimeout()
      } else {
        $timeout.cancel(timeout)
        $scope.doneReview = true
      }
    }

    const nextCard = function() {
      const id   = $scope.cards[$scope.currentIndex].id
      const url  = '/flash_cards/' + id + '/answer'
      const data = { response_quality: $scope.secondsLeft / 3 + 2 }
      $http.post(url, JSON.stringify(data))

      $scope.secondsLeft = 0
      $timeout.cancel(timeout)
      $scope.onTimeout()
    }

    $scope.checkAnswer = function(guess, answer) {
      if (guess == answer) nextCard()
    }

    const scheduleTimeout = function() {
      timeout = $timeout($scope.onTimeout, 1000)
    }

    scheduleTimeout()
  }
}]

angular
  .module('flashCards', [])
  .controller('flashCardController', flashCardController)
