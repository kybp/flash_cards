const app = angular.module('flashCards', [])

app.directive('focusOn', ['$timeout', function($timeout) {
  return function(scope, elements, attrs) {
    scope.$watch(attrs.focusOn, function(value) {
      $timeout(function() {
        if (value) elements[0].focus()
      })
    })
  }
}])

app.controller('ReviewController',
         ['$http', '$scope', '$timeout',
  function($http,   $scope,   $timeout) {

  const NEXT_CARD_URL    = '/flash_cards/next.json'
  const SECONDS_PER_CARD = 10
  const TICKS_PER_SECOND = 15
  let ticks = 0

  $scope.guess        = ''
  $scope.beganReview  = false
  $scope.betweenCards = true

  $scope.getNextCard = function() {
    $timeout.cancel(timeout)
    $http.get(NEXT_CARD_URL)
      .then(function(response) {
        $scope.card         = response.data
        ticks               = SECONDS_PER_CARD * TICKS_PER_SECOND
        $scope.secondsLeft  = SECONDS_PER_CARD
        $scope.betweenCards = false

        const input = document.getElementById('guess-input')
        input.disabled = false
        input.value    = ''
        scheduleTimeout()
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
    if ($scope.guess === '') return
    saveResponseQuality(checkAnswer() ? null : 1)
    waitBetweenCards()
  }

  const saveResponseQuality = function(quality) {
    const url  = '/flash_cards/' + $scope.card.id + '/answer'
    const data = { response_quality: quality || $scope.secondsLeft / 3 + 2 }
    $http.post(url, JSON.stringify(data))
  }

  $scope.answerStatus = function() {
    if (! $scope.betweenCards || ! $scope.card) {
      return 'default'
    } else if (checkAnswer()) {
      return 'success'
    } else {
      return 'danger'
    }
  }

  $scope.beginReview = function() {
    $scope.beganReview = true
    $scope.getNextCard()
  }

  $scope.timePercent = function() {
    return ticks * 100 / (SECONDS_PER_CARD * TICKS_PER_SECOND)
  }

  $scope.timeStatus = function() {
    const percent = $scope.timePercent()
    if      (percent > 66) return 'success'
    else if (percent > 33) return 'warning'
    else                   return 'danger'
  }

  $http.get(NEXT_CARD_URL).then(
    function(response) {
      $scope.card = response.data
    }
  )
}])
