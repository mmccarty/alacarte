var tests = Object.keys(window.__karma__.files).filter(function(file) {
  return /\.spec(\.coffee-compiled)?\.js$/.test(file);
});

requirejs.config({
  baseUrl: '/base/app',
  paths: {
    'angular': 'vendor/angular/angular',
    'angular-mocks': 'vendor/angular-mocks/angular-mocks',
    'angular-scenario': 'vendor/angular-scenario/angular-scenario',
    'codemirror': 'vendor/codemirror/lib/codemirror',
    'codemirror-css': 'vendor/codemirror/mode/css/css',
    'codemirror-htmlmixed': 'vendor/codemirror/mode/htmlmixed/htmlmixed',
    'codemirror-javascript': 'vendor/codemirror/mode/javascript/javascript',
    'codemirror-xml': 'vendor/codemirror/mode/xml/xml',
    'jquery': 'vendor/jquery/jquery',
    'jquery.cookie': 'vendor/jquery.cookie/jquery.cookie',
    'lodash': 'vendor/lodash/lodash',
    'restangular': 'vendor/restangular/src/restangular',
    'tinymce': 'vendor/tinymce-release/tiny_mce',
    'ui.bootstrap.bindHtml': 'vendor/angular-ui-bootstrap/src/bindHtml/bindHtml',
    'ui.bootstrap.buttons': 'vendor/angular-ui-bootstrap/src/buttons/buttons',
    'ui.bootstrap.datepicker': 'vendor/angular-ui-bootstrap/src/datepicker/datepicker',
    'ui.bootstrap.dropdownToggle': 'vendor/angular-ui-bootstrap/src/dropdownToggle/dropdownToggle',
    'ui.bootstrap.modal': 'vendor/angular-ui-bootstrap/src/modal/modal',
    'ui.bootstrap.position': 'vendor/angular-ui-bootstrap/src/position/position',
    'ui.bootstrap.popover': 'vendor/angular-ui-bootstrap/src/popover/popover',
    'ui.bootstrap.tabs': 'vendor/angular-ui-bootstrap/src/tabs/tabs',
    'ui.bootstrap.tooltip': 'vendor/angular-ui-bootstrap/src/tooltip/tooltip',
    'ui.bootstrap.transition': 'vendor/angular-ui-bootstrap/src/transition/transition',
    'ui.codemirror': 'vendor/angular-ui-codemirror/ui-codemirror',
    'ui.tinymce': 'vendor/angular-ui-tinymce/src/tinymce'
  },
  shim: {
    'angular': {
      'exports': 'angular'
    },
    'angular-mocks': {
      deps: ['angular'],
      'exports': 'angular.mock'
    },
    'angular-scenario': {
      deps: ['angular'],
      'exports': 'angular.scenario'
    },
    'codemirror-css': {
      deps: ['codemirror']
    },
    'codemirror-htmlmixed': {
      deps: ['codemirror', 'codemirror-css', 'codemirror-javascript', 'codemirror-xml']
    },
    'codemirror-javascript': {
      deps: ['codemirror']
    },
    'codemirror-xml': {
      deps: ['codemirror']
    },
    'jquery.cookie': {
      deps: ['jquery']
    },
    'restangular': {
      deps: ['angular']
    },
    'ui.bootstrap.buttons': {
      deps: ['angular']
    },
    'ui.bootstrap.datepicker': {
      deps: ['angular']
    },
    'ui.bootstrap.dropdownToggle': {
      deps: ['angular']
    },
    'ui.bootstrap.modal': {
      deps: ['ui.bootstrap.bindHtml']
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
  ],
  deps: tests,
  callback: window.__karma__.start
});
