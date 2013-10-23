define ['angular-mocks', 'nodes/nodes'], ->

  describe 'nodes controller', ->
    $httpBackend = null
    $rootScope   = null
    scope        = null
    ctrl         = null
    nodes        = null

    beforeEach module('dashboard-ui.nodes')

    beforeEach inject((_$rootScope_, $controller) ->
      nodes = [
        {id: 1, shared: false, used: true, label: 'Test node 1'},
        {id: 2, shared: true, used: true, label: 'Test node 2'}
      ]
      $rootScope = _$rootScope_
      scope      = $rootScope.$new()
      ctrl       = $controller('NodesCtrl', { $scope: scope, nodes: nodes })
    )

    describe 'label', ->
      it 'should have injected data', ->
        expect(scope.nodes[0].shared).toBe false
        expect(scope.nodes[1].label).toBe 'Test node 2'