define([
  'lodash',
  'angular',
  'dialogs/message-box'
], function(_, angular) {
  'use strict';

  var module = angular.module('dashboard-ui.navigateAway', ['dashboard-ui.messageBox']);

  module.service('navigateAway', [
    '$location',
    'messageBox',
    function($location, messageBox) {

      function open() {
        return messageBox.open(
          'Unsaved Changes',
          'You have unsaved changes.  Are you sure you want to navigate away?',
          [
            { label: 'Save',    result: 'save',    cssClass: 'btn-primary' },
            { label: 'Discard', result: 'discard', cssClass: 'btn-danger'  },
            { label: 'Cancel',  result: 'cancel' }
          ]);
      }

      function protect(event, setDirty, save) {
        var url = $location.url();
        event.preventDefault();
        open().result.then(function(result) {
          if (result === 'save') {
            save();
            $location.url(url);
          } else if (result === 'discard') {
            setDirty(false);
            $location.url(url);
          }
        });
      }

      return {
        open:    open,
        protect: protect
      };
    }
  ]);

  return module;
});
