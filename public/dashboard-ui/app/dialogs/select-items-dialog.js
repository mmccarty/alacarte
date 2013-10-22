define([
  'lodash',
  'angular',
  'dialogs/input-dialog',
  'ui.bootstrap.dialog'
], function(_, angular) {
  'use strict';

  var module = angular.module('dashboard-ui.selectItemsDialog', [
    'dashboard-ui.inputDialog',
    'ui.bootstrap.dialog'
  ]);

  /*jshint maxparams: false */
  module.controller('SelectItemsDialog', [
    '$dialog',
    '$scope',
    'dialog',
    'model',
    function SelectItemsDialog($dialog, $scope, dialog, model) {
      function getModelValue(model, value, defaultValue) {
        return model && model[value] ? model[value] : defaultValue;
      }
      $scope.title = getModelValue(model, 'title', 'Select');

      $scope.selectedItemSelected = false;
      $scope.selectedItemsModel   = [];

      var selectedItems = getModelValue(model, 'selectedItems', []);
      $scope.selectedItems = _.map(selectedItems, function(item) {
        return { name: item };
      });

      $scope.allItemSelected = false;
      $scope.allItemsModel   = [];

      var allItems = getModelValue(model, 'allItems', []);
      $scope.allItems = _.map(_.difference(allItems, selectedItems), function(item) {
        return { name: item };
      });

      $scope.addNewItem = function() {
        var dialog = $dialog.dialog({
          controller:  'InputDialog',
          templateUrl: 'app/dialogs/input-dialog.tpl.html',
          resolve: {
            model: function() {
              return {
                title:      'Add new topic',
                directions: 'Please enter a new topic:'
              };
            }
          }
        });

        dialog.open().then(function(topic) {
          if (topic) {
            $scope.selectedItems.push({ name: topic });
          }
        });
      };
      $scope.close = function(result) {
        result = result && _.pluck(result, 'name');
        dialog.close(result);
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

  module.service('selectItemsDialog', ['$dialog', function($dialog) {
    function dialog(title, allItems, selectedItems) {
      return $dialog.dialog({
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

    return { dialog: dialog };
  }]);

  return module;
});
