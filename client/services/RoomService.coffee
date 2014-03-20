'use strict'

angular.module('app')
  .service 'RoomService', ($http) ->

    rooms: () ->
      $http.get("api/room")

    users: (room) ->
      $http.get("api/room/#{ room }/users")