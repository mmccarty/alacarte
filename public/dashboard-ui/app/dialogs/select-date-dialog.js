define([
  'angular',
  'ui.bootstrap.datepicker',
  'ui.bootstrap.modal'
], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.selectDateDialog', [
    'ui.bootstrap.datepicker',
    'ui.bootstrap.modal'
  ]);

  module.controller('SelectDateDialog', [
    '$scope', '$modalInstance',
    function SelectDateDialog($scope, $modalInstance) {
      $scope.close = function(result) {
        $modalInstance.close(result);
      };
    }
  ]);

  module.service('selectDateDialog', ['$modal', function($modal) {
    function open() {
      return $modal.open({
        controller: 'SelectDateDialog',
        templateUrl: 'app/dialogs/select-date-dialog.tpl.html'
      });
    }

    return { open: open };
  }]);

  return module;
});
