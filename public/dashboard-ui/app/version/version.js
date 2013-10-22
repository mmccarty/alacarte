define(['angular'], function(angular) {
  'use strict';

  var module = angular.module('dashboard-ui.version', []);
  module.value('version', '0.1.0-SNAPSHOT');
  return module;
});
