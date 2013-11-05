/*globals angular, jQuery, require, requirejs */
requirejs.config({
  baseUrl: 'app',
  paths: {
    'ckeditor': 'vendor/ckeditor/ckeditor',
    'codemirror': 'vendor/codemirror/lib/codemirror',
    'codemirror-css': 'vendor/codemirror/mode/css/css',
    'codemirror-htmlmixed': 'vendor/codemirror/mode/htmlmixed/htmlmixed',
    'codemirror-javascript': 'vendor/codemirror/mode/javascript/javascript',
    'codemirror-xml': 'vendor/codemirror/mode/xml/xml',
    'jquery.cookie': 'vendor/jquery.cookie/jquery.cookie',
    'lodash': 'vendor/lodash/dist/lodash.compat.min',
    'restangular': 'vendor/restangular/dist/restangular.min',
    'tinymce': 'vendor/tinymce-release/tiny_mce',
    'ui.bootstrap.bindHtml': 'vendor/angular-ui-bootstrap/src/bindHtml/bindHtml',
    'ui.bootstrap.buttons': 'vendor/angular-ui-bootstrap/src/buttons/buttons',
    'ui.bootstrap.dropdownToggle': 'vendor/angular-ui-bootstrap/src/dropdownToggle/dropdownToggle',
    'ui.bootstrap.modal': 'vendor/angular-ui-bootstrap/src/modal/modal',
    'ui.bootstrap.position': 'vendor/angular-ui-bootstrap/src/position/position',
    'ui.bootstrap.popover': 'vendor/herp/derp',
    'ui.bootstrap.tabs': 'vendor/angular-ui-bootstrap/src/tabs/tabs',
    'ui.bootstrap.datepicker': 'vendor/angular-ui-bootstrap/src/datepicker/datepicker',
    'ui.bootstrap.tooltip': 'vendor/angular-ui-bootstrap/src/tooltip/tooltip',
    'ui.bootstrap.transition': 'vendor/angular-ui-bootstrap/src/transition/transition',
    'ui.codemirror': 'vendor/angular-ui-codemirror/ui-codemirror',
    'ui.tinymce': 'vendor/angular-ui-tinymce/src/tinymce'
  },
  shim: {
    'codemirror-css': {
      deps: ['codemirror']
    },
    'codemirror-htmlmixed': {
      deps: ['codemirror-css', 'codemirror-javascript', 'codemirror-xml']
    },
    'codemirror-javascript': {
      deps: ['codemirror']
    },
    'codemirror-xml': {
      deps: ['codemirror']
    },
    'jquery.cookie': {
      deps: ['jquery'],
      exports: 'jQuery.fn.cookie'
    },
    'restangular': {
      deps: ['angular', 'lodash']
    },
    'ui.bootstrap.bindHtml': {
      deps: ['angular']
    },
    'ui.bootstrap.buttons': {
      deps: ['angular']
    },
    'ui.bootstrap.dropdownToggle': {
      deps: ['angular']
    },
    'ui.bootstrap.modal': {
    },
    'ui.bootstrap.popover': {
      deps: ['ui.bootstrap.tooltip']
    },
    'ui.bootstrap.position': {
      deps: ['angular']
    },
    'ui.bootstrap.tabs': {
      deps: ['angular']
    },
    'ui.bootstrap.datepicker': {
      deps: ['angular']
    },
    'ui.bootstrap.tooltip': {
      deps: ['ui.bootstrap.position']
    },
    'ui.bootstrap.transition': {
      deps: ['angular']
    },
    'ui.codemirror': {
      deps: ['angular', 'codemirror-htmlmixed']
    },
    'ui.tinymce': {
      deps: ['angular', 'tinymce']
    }
  },
  priority: [
    'angular'
  ]
});

if (typeof jQuery === 'function') {
  define('jquery',  function() {  'use strict'; return jQuery;  });
}

if (angular) {
  define('angular', function() {  'use strict'; return angular; });
}

require(['jquery', 'angular', 'app'], function($, angular) {
  'use strict';

  $(function() {
    var $html = $('html');
    angular.bootstrap($html, ['dashboard-ui']);
    $html.addClass('ng-app');
  });
});
