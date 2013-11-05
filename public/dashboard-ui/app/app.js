define([
  'angular',
  'filters',
  'nodes/nodes',
  'restangular',
], function(angular) {
  'use strict';

  var dashboard = angular.module('dashboard-ui', [
    'dashboard-ui.filters',
    'dashboard-ui.nodes',
    'restangular'
  ]);

  dashboard.controller('DashboardCtrl', function() {
  });
});
