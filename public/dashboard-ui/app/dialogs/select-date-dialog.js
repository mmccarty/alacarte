define([
  'angular',
  'ui.bootstrap.datepicker',
  'ui.bootstrap.dialog'
], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.selectDateDialog', [
    'ui.bootstrap.datepicker',
    'ui.bootstrap.dialog'
  ]);

  module.controller('SelectDateDialog', [
    '$scope', 'dialog',
    function SelectDateDialog($scope, dialog) {
      $scope.close = function(result) {
        dialog.close(result);
      };
    }
  ]);

  module.service('selectDateDialog', ['$dialog', function($dialog) {
    function dialog() {
      return $dialog.dialog({
        controller: 'SelectDateDialog',
        templateUrl: 'app/dialogs/select-date-dialog.tpl.html'
      });
    }

    return { dialog: dialog };
  }]);

  return module;
});
