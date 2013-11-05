define([
  'angular'
], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.filters', []).
      filter('truncate', function () {
        function truncated(text, length, end) {
          if (text.length <= length || text.length - end.length <= length) {
            return text;
          }
          else {
            return String(text).substring(0, length-end.length) + end;
          }
        }
        return function (text, length, end) {
          length = typeof length !== 'undefined' ? length : 10;
          end = typeof end !== 'undefined' ? end : '...';
          return truncated(text, length, end);
        };
      });

  return module;
});