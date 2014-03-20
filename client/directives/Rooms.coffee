'use strict'

angular.module('app')
  .directive 'rooms', ($location, RoomService, ChatService) ->

    templateUrl: 'templates/rooms.tpl.html'

    restrict: 'A'

    link: (scope, element, attrs) ->
      element.addClass("rooms")

      listRooms = () ->
        RoomService.rooms().success (rooms) ->
          scope.rooms = rooms
          setTimeout( listRooms, 10000 )

      listRooms()

      scope.createRoom = (e) ->
        if e.keyCode == 13
          $location.path "/chat/#{ scope.roomName }"
          scope.roomName = ""