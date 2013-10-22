define(['angular', 'ui.bootstrap.dialog'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.inputDialog', [
    'ui.bootstrap.dialog'
  ]);

  module.controller('InputDialog', [
    '$scope',
    'dialog',
    'model',
    function InputDialog($scope, dialog, model) {
      function getDefault(param, defaultValue) {
        return model && model[param] ? model[param] : defaultValue;
      }

      $scope.directions = getDefault('directions', 'Please provide a value:');

      $scope.title = getDefault('title', 'Input');

      $scope.userInput             = getDefault('value', '');
      $scope.userInputPattern      = getDefault('pattern', /.*/);
      $scope.userInputPatternError = getDefault('patternError', /.*/);
      $scope.userInputRequired     = getDefault('required', true);

      $scope.close = function(result) {
        dialog.close(result);
      };
    }
  ]);

  module.service('inputDialog', ['$dialog', function($dialog) {
    /*jshint maxparams:false */
    function dialog(title, directions, pattern, patternError, value, required) {
      return $dialog.dialog({
        controller:  'InputDialog',
        templateUrl: 'app/dialogs/input-dialog.tpl.html',
        resolve:     {
          model: function() {
            return {
              title:        title,
              directions:   directions,
              pattern:      pattern,
              patternError: patternError,
              value:        value,
              required:     required
            };
          }
        }
      });
    }

    return { dialog: dialog };
  }]);

  return module;
});
