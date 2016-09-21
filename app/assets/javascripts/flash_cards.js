const app = angular.module('flashCards', [])
$(document).on('turbolinks:load', function() {
  angular.bootstrap(document.body, ['flashCards'])
})

app.directive('clickToEdit', function() {
  return {
    scope: { field: '=', onSubmit: '&', onCancel: '&' },

    controller: ['$scope', function($scope) {
      this.editing = false

      this.startEditing = function() {
        this.editing = true
      }

      this.stopEditing = function() {
        this.editing = false
      }

      this.submit = function() {
        this.editing = false
        $scope.onSubmit()
      }

      this.cancel = function() {
        this.editing = false
        $scope.onCancel()
      }
    }],

    controllerAs: '$ctrl',

    template: '\
      <span ng-hide="$ctrl.editing"\
            ng-click="$ctrl.startEditing()"\
            class="h4">\
        {{field}}\
      </span>\
\
      <form ng-show="$ctrl.editing" ng-submit="$ctrl.submit()">\
        <input type="text"\
               ng-model="field"\
               on-escape-key="$ctrl.cancel()"\
               focus-on="$ctrl.editing"\
               class="form-control" />\
      </form>\
    '
  }
})

app.directive('onEscapeKey', function() {
  const escapeKey = 27

  return function(scope, element, attrs) {
    element.bind('keydown', function(event) {
      if (event.which === escapeKey) {
        event.preventDefault()
        scope.$apply(attrs.onEscapeKey)
      }
    })
  }
})

app.directive('focusOn', ['$timeout', function($timeout) {
  return function(scope, elements, attrs) {
    scope.$watch(attrs.focusOn, function(value) {
      $timeout(function() {
        if (value) {
          elements[0].focus()
        } else {
          elements[0].blur()
        }
      })
    })
  }
}])

app.controller('ManagementController',
         ['$http', '$scope',
  function($http,   $scope) {

  $scope.cards = []

  $scope.getCards = function() {
    $http.get('/flash_cards.json')
      .then(function(response) {
        $scope.cards = response.data
      }, function(response) {
        alert('error fetching cards: ' + response.status)
      })
  }

  $scope.deleteCard = function(card) {
    $http.delete('/flash_cards/' + card.id)
      .then(function() {
        $scope.cards.splice($scope.cards.indexOf(card), 1)
      }, function(response) {
        alert('error deleting card: ' + response.status)
      })
  }

  $scope.resetCard = function(card) {
    $http.get('/flash_cards/' + card.id)
      .then(function(response) {
        $scope.cards[$scope.cards.indexOf(card)] = response.data
      })
  }

  $scope.saveChanges = function(card) {
    $http.put('/flash_cards/' + card.id, {
      question: card.question,
      answer:   card.answer
    }).then(function() {},
      function() {
        $scope.resetCard(card)
        alert('error saving card')
      })
  }

  $scope.search = function(term) {
    if (term.length === 0) {
      $scope.getCards()
    } else {
      $http.get('/flash_cards/search', { params: { term: term } })
        .then(function(response) {
          $scope.cards = response.data
        }, function(response) {
          alert('error fetching cards: ' + response.status)
        })
    }
  }

  $scope.getCards()
}])

app.controller('ReviewController',
         ['$http', '$scope', '$timeout',
  function($http,   $scope,   $timeout) {

  const NEXT_CARD_URL    = '/flash_cards/next.json'
  const SECONDS_PER_CARD = 10
  const TICKS_PER_SECOND = 15
  var ticks = 0

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

  var timeout

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
    const data =
      { response_quality: quality || $scope.secondsLeft / 3 + 2 }
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
