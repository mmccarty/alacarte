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
    '$log',
    'nodes',
    'Restangular',
    function($scope, $modal, $log, nodes, Restangular) {
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
              }, function () {
                $log.info('Modal dismissed at: ' + new Date());
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

      $scope.ok = function () {
        console.log($scope.node.content);
        $modalInstance.close($scope.node);
      };

      $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
      };
    }
  ]);

  return module;
});