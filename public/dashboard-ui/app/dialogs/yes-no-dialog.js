define([
  'lodash',
  'angular',
  'ui.bootstrap.dialog'
], function(_, angular) {
  'use strict';

  var module = angular.module('dashboard-ui.yesNoDialog', ['ui.bootstrap.dialog']);

  module.service('yesNoDialog', ['$dialog', function($dialog) {
    function dialog(title, header) {
      return $dialog.messageBox(
        title,
        header,
        [
          { label: 'Yes', result: 'yes', cssClass: 'btn btn-primary' },
          { label: 'No',  result: 'no',  cssClass: 'btn' }
        ]);
    }

    return {
      dialog: dialog
    };
  }]);

  return module;
});
