define(['angular', 'ui.bootstrap.modal'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.messageBox', [
    'ui.bootstrap.modal'
  ]);

  module.controller('MessageBox', [
    '$scope',
    '$modalInstance',
    'model',
    function MessageBox($scope, $modalInstance, model) {
      function getDefault(param, defaultValue) {
        return model && model[param] ? model[param] : defaultValue;
      }

      $scope.title   = getDefault('title', 'Message');
      $scope.message = getDefault('message', 'Ok?');
      $scope.buttons = getDefault('buttons', [{ label: 'Ok', result: 'ok' }]);

      $scope.close = function(result) {
        $modalInstance.close(result);
      };
    }
  ]);

  module.service('messageBox', ['$modal', function($modal) {
    function open(title, message, buttons) {
      return $modal.open({
        controller:  'MessageBox',
        templateUrl: 'app/dialogs/message-box.tpl.html',
        resolve:     {
          model: function() {
            return {
              title:   title,
              message: message,
              buttons: buttons,
            };
          }
        }
      });
    }

    return { open: open };
  }]);

  return module;
});
