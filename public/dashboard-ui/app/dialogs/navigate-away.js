define([
  'lodash',
  'angular',
  'ui.bootstrap.dialog'
], function(_, angular) {
  'use strict';

  var module = angular.module('dashboard-ui.navigateAway', ['ui.bootstrap.dialog']);

  module.service('navigateAway', [
    '$dialog',
    '$location',
    function($dialog, $location) {

      function dialog() {
        return $dialog.messageBox(
          'Unsaved Changes',
          'You have unsaved changes.  Are you sure you want to navigate away?',
          [
            { label: 'Save',    result: 'save',    cssClass: 'btn btn-primary' },
            { label: 'Discard', result: 'discard', cssClass: 'btn btn-danger'  },
            { label: 'Cancel',  result: 'cancel',  cssClass: 'btn'  }
          ]);
      }

      function protect(event, setDirty, save) {
        var url = $location.url();
        event.preventDefault();
        dialog().open().then(function(result) {
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
        dialog:  dialog,
        protect: protect
      };
    }
  ]);

  return module;
});
