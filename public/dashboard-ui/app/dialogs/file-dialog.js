define(['angular', 'ui.bootstrap.dialog'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.fileDialog', [
    'ui.bootstrap.dialog'
  ]);

  module.controller('FileDialog', [
    '$scope',
    'dialog',
    'model',
    function FileDialog($scope, dialog, model) {
      function getDefault(param, defaultValue) {
        return model && model[param] ? model[param] : defaultValue;
      }

      $scope.title = getDefault('title', 'File uploader');

      $scope.file = null;
      $scope.uploadFile = function(file) {
        $scope.file = file;
      };

      $scope.close = function(result) {
        dialog.close(result && $scope.file);
      };
    }
  ]);

  module.service('fileDialog', ['$dialog', function($dialog) {
    function dialog(title) {
      return $dialog.dialog({
        controller:  'FileDialog',
        templateUrl: 'app/dialogs/file-dialog.tpl.html',
        resolve:     {
          model: function() {
            return {
              title:        title
            };
          }
        }
      });
    }

    return { dialog: dialog };
  }]);

  module.service('fileUpload', ['$http', function($http) {
    function upload(url, file) {
      return $http({
        method:  'POST',
        url:     url,
        headers: { 'Content-Type': undefined },
        transformRequest: function() {
          var formData = new FormData();
          formData.append('file', file);
          return formData;
        }
      });
    }

    return { upload: upload };
  }]);

  return module;
});
