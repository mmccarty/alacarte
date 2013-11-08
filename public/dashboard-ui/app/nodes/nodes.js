define([
  'angular',
  'restangular',
  'ck-editor/ck-editor',
  'dialogs/yes-no-dialog',
  'ui.bootstrap',
], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.nodes', [
    'dashboard-ui.ckeditor',
    'dashboard-ui.yesNoDialog',
    'restangular',
    'ui.bootstrap',
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
    'yesNoDialog',
    /*jshint maxparams:false */
    function($scope, $modal, nodes, yesNoDialog) {
      $scope.nodes = nodes;

      $scope.editNode = function (node) {
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
      };

      $scope.deleteNode = function (node) {
        yesNoDialog
            .open(
                'Delete node?',
                'This will remove "' + node.label + '". Are you sure?')
            .result.then(function(result) {
              if (result === 'yes') {
                node.remove().then(function() {
                  $scope.nodes.splice(nodes.indexOf(node), 1);
                });
              }
            });
      };

      $scope.copyNode = function (node) {
        node.post('copy')
             .then(function(result) {
               nodes.unshift(result);
         });
      };
    }
  ]);

  module.controller('ModalInstanceCtrl', [
    '$scope',
    '$modalInstance',
    'node',
    function($scope, $modalInstance, node) {
      $scope.error   = false;
      $scope.message = null;
      $scope.node    = node;

      $scope.save = function() {
        node.put().then(function() {
          $scope.message = 'Saved';
          $scope.error = false;
          $modalInstance.close($scope.node);
        }, function() {
          $scope.message = 'There was an error saving.';
          $scope.error = true;
        });
      };

      $scope.cancel = function() {
        $modalInstance.dismiss('cancel');
      };
    }
  ]);

  return module;
});
