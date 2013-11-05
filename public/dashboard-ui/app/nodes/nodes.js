define([
  'angular',
  'filters',
  'restangular',
  'ui.bootstrap.bindHtml',
  'ui.bootstrap.modal',
  'ui.bootstrap.popover'
], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.nodes', [
    'dashboard-ui.filters',
    'restangular',
    'ui.bootstrap.bindHtml',
    'ui.bootstrap.modal',
    'ui.bootstrap.popover'
  ]);

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
    '$modal',
    'nodes',
    'Restangular',
    function($scope, $modal, nodes, Restangular) {
      $scope.nodes = nodes;

      $scope.editNode = function (id) {
        Restangular.one('nodes', id).get({ format: 'json' }).
            then(function(node){
              var modalInstance = $modal.open({
                templateUrl: 'app/nodes/edit.tpl.html',
                controller: 'ModalInstanceCtrl',
                resolve: {
                  node: function () {
                    return node;
                  }
                },
                windowClass: 'full-screen'
              });

              modalInstance.result.then(function () {
              });
        });
      };
    }
  ]);

  module.controller('ModalInstanceCtrl', [
    '$scope',
    '$modalInstance',
    'node',
    function($scope, $modalInstance, node) {

      $scope.node = node;

      $scope.save = function () {
        node.put().then(function(node){
          $scope.message = 'Saved';
          $scope.error = false;
          $modalInstance.close($scope.node);
        }, function () {
          $scope.message = 'There was an error saving.';
          $scope.error = true;
          $('#flash').show();
        });
      };

      $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
      };
    }
  ]);

  return module;
});