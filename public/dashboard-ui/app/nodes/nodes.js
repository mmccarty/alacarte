define([
  'angular'
], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.nodes', []);

  module.config(['$routeProvider',
    function($routeProvider) {
      $routeProvider.when('/nodes', {
        templateUrl: 'app/nodes/nodes.tpl.html',
        controller: 'NodesCtrl',
        resolve: {
          nodes: ['Restangular', function(Restangular) {
            return Restangular.all('nodes').getList();
          }]
        }
      });
    }]);

  module.controller('NodesCtrl', [
    '$scope',
    'nodes',
    function($scope, nodes) {
      $scope.nodes = nodes;
    }
  ]);
  return module;
});