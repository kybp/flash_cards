const flashCardController =
['$http', '$scope', '$timeout', function($http, $scope, $timeout) {
  const SECONDS_PER_CARD = 10
  const TICKS_PER_SECOND = 15
  let ticks = 0

  $scope.guess        = ''
  $scope.beganReview  = false
  $scope.betweenCards = false

  $scope.getNextCard = function(shouldStartTimerAfterFetch) {
    $http.get('/flash_cards/next.json')
      .then(function(response) {
        $scope.card         = response.data
        ticks               = SECONDS_PER_CARD * TICKS_PER_SECOND
        $scope.secondsLeft  = SECONDS_PER_CARD
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
    const ms = 1000 / TICKS_PER_SECOND
    timeout = $timeout($scope.onTimeout, ms)
  }

  const waitBetweenCards = function() {
    document.getElementById('guess-input').disabled = true
    $scope.betweenCards = true
  }

  $scope.onTimeout = function() {
    --ticks
    if (ticks % TICKS_PER_SECOND === 0) --$scope.secondsLeft

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

  $scope.timePercent = function() {
    return ticks * 100 / (SECONDS_PER_CARD * TICKS_PER_SECOND)
  }

  $scope.timeStatus = function() {
    const percent = $scope.timePercent()
    if (percent > 66)      return 'success'
    else if (percent > 33) return 'warning'
    else                   return 'danger'
  }

  $scope.getNextCard(false)
}]

angular
  .module('flashCards', [])
  .controller('flashCardController', flashCardController)
