define(['angular', 'ui.bootstrap.dialog'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.textareaDialog', [
    'ui.bootstrap.dialog'
  ]);

  module.controller('TextareaDialog', [
    '$scope',
    'dialog',
    'model',
    function TextareaDialog($scope, dialog, model) {
      function getDefault(param, defaultValue) {
        return model && model[param] ? model[param] : defaultValue;
      }

      $scope.directions = getDefault('directions', 'Please provide a value:');
      $scope.title = getDefault('title', 'Input');
      $scope.close = function(result) {
        dialog.close(result);
      };
    }
  ]);

  module.service('textareaDialog', ['$dialog', function($dialog) {
    /*jshint maxparams:false */
    function dialog(title, directions) {
      return $dialog.dialog({
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

    return { dialog: dialog };
  }]);

  return module;
});
