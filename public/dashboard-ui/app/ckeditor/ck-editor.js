define(['angular', 'ckeditor'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.ckeditor', []);

  /*jshint maxparams:false */
  module.directive('ckEditorInline', function() {
    return {
      require: '?ngModel',
      link: function($scope, element, attrs, ngModel) {
        var options = $scope.$eval(attrs.ckEditorOptions),
        ck = CKEDITOR.inline(element[0], options);

        ck.on('instanceReady', function() {
          ck.setData(ngModel.$viewValue);
        });

        ck.on('pasteState', function() {
          $scope.$apply(function() {
            ngModel.$setViewValue(ck.getData());
          });
        });

        ngModel.$render = function() {
          ck.setData(ngModel.$modelValue);
        };
      }
    };
  });

  /*jshint maxparams:false */
  module.directive('ckEditor', function() {
    return {
      require: '?ngModel',
      link: function($scope, element, attrs, ngModel) {
        var options = $scope.$eval(attrs.ckEditorOptions),
        ck = CKEDITOR.replace(element[0], options);

        ck.on('instanceReady', function() {
          ck.setData(ngModel.$viewValue);
        });

        function updateModel() {
          function update() {
            ngModel.$setViewValue(ck.getData());
          }
          if ($scope.$$phase || $scope.$root.$$phase) {
            update();
          } else {
            $scope.$apply(update);
          }
        }

        ck.on('change',     updateModel);
        ck.on('dataReady',  updateModel);
        ck.on('key',        updateModel);

        ngModel.$render = function() {
          ck.setData(ngModel.$modelValue);
        };
      }
    };
  });
  return module;
});
