define(['angular', 'ui.bootstrap.modal'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.fileDialog', [
    'ui.bootstrap.modal'
  ]);

  module.controller('FileDialog', [
    '$scope',
    '$modalInstance',
    'model',
    function FileDialog($scope, $modalInstance, model) {
      function getDefault(param, defaultValue) {
        return model && model[param] ? model[param] : defaultValue;
      }

      $scope.title = getDefault('title', 'File uploader');

      $scope.file = null;
      $scope.uploadFile = function(file) {
        $scope.file = file;
      };

      $scope.close = function(result) {
        $modalInstance.close(result && $scope.file);
      };
    }
  ]);

  module.service('fileDialog', ['$modal', function($modal) {
    function open(title) {
      return $modal.open({
        controller:  'FileDialog',
        templateUrl: 'app/dialogs/file-dialog.tpl.html',
        resolve:     {
          model: function() {
            return {
              title: title
            };
          }
        }
      });
    }

    return { open: open };
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
