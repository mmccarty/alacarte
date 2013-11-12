/*globals angular, jQuery, require, requirejs */
requirejs.config({
  baseUrl: 'app',
  paths: {
    'angular-dragdrop': 'vendor/angular-dragdrop/src/angular-dragdrop.min',
    'ckeditor': 'vendor/ckeditor/ckeditor',
    'codemirror': 'vendor/codemirror/lib/codemirror',
    'codemirror-css': 'vendor/codemirror/mode/css/css',
    'codemirror-htmlmixed': 'vendor/codemirror/mode/htmlmixed/htmlmixed',
    'codemirror-javascript': 'vendor/codemirror/mode/javascript/javascript',
    'codemirror-xml': 'vendor/codemirror/mode/xml/xml',
    'jquery.cookie': 'vendor/jquery.cookie/jquery.cookie',
    'jquery.ui': 'vendor/jquery-ui/ui/jquery-ui',
    'lodash': 'vendor/lodash/dist/lodash.compat.min',
    'restangular': 'vendor/restangular/dist/restangular.min',
    'tinymce': 'vendor/tinymce-release/tiny_mce',
    'ui.bootstrap': 'vendor/angular-bootstrap/ui-bootstrap-tpls.min',
    'ui.codemirror': 'vendor/angular-ui-codemirror/ui-codemirror',
    'ui.tinymce': 'vendor/angular-ui-tinymce/src/tinymce'
  },
  shim: {
    'angular-dragdrop': {
      deps: ['jquery.ui']
    },
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
    'ui.bootstrap': {
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
