define(['angular', 'ui.bootstrap.modal'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.textareaDialog', [
    'ui.bootstrap.modal'
  ]);

  module.controller('TextareaDialog', [
    '$scope',
    '$modalInstance',
    'model',
    function TextareaDialog($scope, $modalInstance, model) {
      function getDefault(param, defaultValue) {
        return model && model[param] ? model[param] : defaultValue;
      }

      $scope.directions = getDefault('directions', 'Please provide a value:');
      $scope.title = getDefault('title', 'Input');
      $scope.close = function(result) {
        $modalInstance.close(result);
      };
    }
  ]);

  module.service('textareaDialog', ['$modal', function($modal) {
    function open(title, directions) {
      return $modal.open({
        controller:  'TextareaDialog',
        templateUrl: 'app/dialogs/textarea-dialog.tpl.html',
        resolve:     {
          model: function() {
            return {
              title:        title,
              directions:   directions
            };
          }
        }
      });
    }

    return { open: open };
  }]);

  return module;
});
