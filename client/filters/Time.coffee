'use strict';

angular.module('app')
  .filter 'time', () ->
    (input) ->
      if input instanceof Date
        moment(input).format('HH:mm')
      else
        moment(input, "YYYY-MM-DDTHH:mm:ss.SSSSZ").format('HH:mm')