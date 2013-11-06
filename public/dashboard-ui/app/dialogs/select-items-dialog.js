define([
  'lodash',
  'angular',
  'dialogs/input-dialog',
  'ui.bootstrap.modal'
], function(_, angular) {
  'use strict';

  var module = angular.module('dashboard-ui.selectItemsDialog', [
    'dashboard-ui.inputDialog',
    'ui.bootstrap.modal'
  ]);

  /*jshint maxparams: false */
  module.controller('SelectItemsDialog', [
    '$scope',
    '$modalInstance',
    'inputDialog',
    'model',
    function SelectItemsDialog($scope, $modalInstance, inputDialog, model) {
      function getDefault(param, defaultValue) {
        return model && model[param] ? model[param] : defaultValue;
      }

      $scope.title = getDefault('title', 'Select');

      $scope.selectedItemSelected = false;
      $scope.selectedItemsModel   = [];

      var selectedItems = getDefault('selectedItems', []);
      $scope.selectedItems = _.map(selectedItems, function(item) {
        return { name: item };
      });

      $scope.allItemSelected = false;
      $scope.allItemsModel   = [];

      var allItems = getDefault('allItems', []);
      $scope.allItems = _.map(_.difference(allItems, selectedItems), function(item) {
        return { name: item };
      });

      $scope.addNewItem = function() {
        inputDialog.open('Add new topic', 'Please enter a new topic')
          .result
          .then(function(topic) {
          if (topic) {
            $scope.selectedItems.push({ name: topic });
          }
        });
      };

      $scope.close = function(result) {
        result = result && _.pluck(result, 'name');
        $modalInstance.close(result);
      };

      $scope.selectFromAll = function() {
        $scope.allItemSelected = $scope.allItemsModel.length > 0;
      };

      $scope.selectFromSelected = function() {
        $scope.selectedItemSelected = $scope.selectedItemsModel.length > 0;
      };

      $scope.moveToSelectedItems = function() {
        var selected = _.filter($scope.allItems, function(item) {
          return $scope.allItemsModel.indexOf(item.name) !== -1;
        });

        $scope.selectedItems = _.union($scope.selectedItems, selected);
        $scope.allItems = _.difference($scope.allItems, selected);
        $scope.allItemSelected = false;
      };

      $scope.removeFromSelectedItems = function() {
        var selected = _.filter($scope.selectedItems, function(item) {
          return $scope.selectedItemsModel.indexOf(item.name) !== -1;
        });

        $scope.allItems = _.union($scope.allItems, selected);
        $scope.selectedItems = _.difference($scope.selectedItems, selected);
        $scope.selectedItemSelected = false;
      };
    }
  ]);

  module.service('selectItemsDialog', ['$modal', function($modal) {
    function open(title, allItems, selectedItems) {
      return $modal.open({
        controller: 'SelectItemsDialog',
        templateUrl: 'app/dialogs/select-items-dialog.tpl.html',
        resolve: {
          model: function() {
            return {
              title:         title,
              allItems:      allItems,
              selectedItems: selectedItems,
            };
          }
        }
      });
    }

    return { open: open };
  }]);

  return module;
});
