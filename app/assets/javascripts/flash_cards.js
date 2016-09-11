const flashCardController =
['$http', '$scope', '$timeout', function($http, $scope, $timeout) {
  $scope.guess        = ''
  $scope.beganReview  = false
  $scope.betweenCards = false

  $scope.getNextCard = function(shouldStartTimerAfterFetch) {
    $http.get('/flash_cards/next.json')
      .then(function(response) {
        $scope.card         = response.data
        $scope.secondsLeft  = 10
        $scope.betweenCards = false

        const input = document.getElementById('guess-input')
        input.disabled = false
        input.value    = ''
        if (shouldStartTimerAfterFetch) scheduleTimeout()
      }, function(response) {
        alert('error fetching card: ' + response.status)
      })
  }

  let timeout

  const scheduleTimeout = function() {
    timeout = $timeout($scope.onTimeout, 1000)
  }

  const waitBetweenCards = function() {
    document.getElementById('guess-input').disabled = true
    $scope.betweenCards = true
  }

  $scope.onTimeout = function() {
    --$scope.secondsLeft

    if ($scope.secondsLeft <= 0) {
      waitBetweenCards()
    } else {
      scheduleTimeout()
    }
  }

  const checkAnswer = function() {
    return $scope.guess === $scope.card.answer
  }

  $scope.submitAnswer = function() {
    if (checkAnswer()) {
      $timeout.cancel(timeout)
      saveResponseQuality()
    }
    waitBetweenCards()
  }

  const saveResponseQuality = function() {
    const url  = '/flash_cards/' + $scope.card.id + '/answer'
    const data = { response_quality: $scope.secondsLeft / 3 + 2 }
    $http.post(url, JSON.stringify(data))
  }

  $scope.answerStatus = function() {
    if (! $scope.betweenCards) {
      return 'default'
    } else if (checkAnswer()) {
      return 'success'
    } else {
      return 'danger'
    }
  }

  $scope.beginReview = function() {
    $scope.beganReview = true
    scheduleTimeout()
  }

  $scope.getNextCard(false)
}]

angular
  .module('flashCards', [])
  .controller('flashCardController', flashCardController)
