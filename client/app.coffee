'use strict'

angular.module('app', [
  'appTemplates', 'ngRoute'
])
  .config ($routeProvider, $httpProvider) ->

    $routeProvider
      .when '/',
        templateUrl: 'templates/chat.tpl.html'
        controller: 'ChatController'
      .when '/login',
        templateUrl: 'templates/login.tpl.html'
        controller: 'LoginController'
      .otherwise
        redirectTo: '/'

    $httpProvider.defaults.headers.common = { 'Content-Type' : 'application/json' }