define([
  'lodash',
  'angular',
  'dialogs/message-box'
], function(_, angular) {
  'use strict';

  var module = angular.module('dashboard-ui.yesNoDialog', ['dashboard-ui.messageBox']);

  module.service('yesNoDialog', ['messageBox', function(messageBox) {
    function open(title, header) {
      return messageBox.open(
        title,
        header,
        [
          { label: 'Yes', result: 'yes', cssClass: 'btn btn-primary' },
          { label: 'No',  result: 'no',  cssClass: 'btn' }
        ]);
    }

    return {
      open: open
    };
  }]);

  return module;
});
