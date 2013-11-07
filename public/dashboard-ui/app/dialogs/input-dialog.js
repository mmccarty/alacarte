define(['angular', 'ui.bootstrap'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.inputDialog', [
    'ui.bootstrap.modal'
  ]);

  module.controller('InputDialog', [
    '$scope',
    '$modalInstance',
    'model',
    function InputDialog($scope, $modalInstance, model) {
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
        $modalInstance.close(result);
      };
    }
  ]);

  module.service('inputDialog', ['$modal', function($modal) {
    /*jshint maxparams:false */
    function open(title, directions, pattern, patternError, value, required) {
      return $modal.open({
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

    return { open: open };
  }]);

  return module;
});
