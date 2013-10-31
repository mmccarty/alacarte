define([
  'angular',
  'ui.bootstrap.bindHtml',
  'ui.bootstrap.modal',
  'ui.bootstrap.popover'
], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.nodes', [
    'filters',
    'ui.bootstrap.bindHtml',
    'ui.bootstrap.modal',
    'ui.bootstrap.popover'
  ]);

  angular.module('filters', []).
      filter('truncate', function () {
        return function (text, length, end) {
          if (isNaN(length))
            length = 10;

          if (end === undefined)
            end = "...";

          if (text.length <= length || text.length - end.length <= length) {
            return text;
          }
          else {
            return String(text).substring(0, length-end.length) + end;
          }

        };
      });

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
    function($scope, $modal, $log, nodes) {
      $scope.nodes = nodes;

      $scope.items = ['item1', 'item2', 'item3'];

      $scope.editNode = function (id) {
        console.log(id);
        $scope.id = id;
        var modalInstance = $modal.open({
          templateUrl: 'app/nodes/edit.tpl.html',
          controller: 'ModalInstanceCtrl',
          resolve: {
            items: function () {
              return $scope.items;
            }
          },
          windowClass: 'full-screen'
        });

        modalInstance.result.then(function (selectedItem) {
          $scope.selected = selectedItem;
        }, function () {
          $log.info('Modal dismissed at: ' + new Date());
        });
      };
    }
  ]);

  module.controller('ModalInstanceCtrl', [
    '$scope',
    '$modalInstance',
    'items',
    function($scope, $modalInstance, items) {

      $scope.items = items;
      $scope.selected = {
        item: $scope.items[0]
      };

      $scope.ok = function () {
        $modalInstance.close($scope.selected.item);
      };

      $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
      };
    }
  ]);

  return module;
});