'use strict'

angular.module('app')
  .service 'RoomService', ($http) ->

    users: (room) ->
      $http.get("api/room/#{ room }/users")