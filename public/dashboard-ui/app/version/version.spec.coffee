define ['angular-mocks', 'version/version'], ->
  describe 'version', ->
    beforeEach module('dashboard-ui.version')
    it 'should inject the current version', inject((version) ->
      expect(version).toBe '0.1.0-SNAPSHOT'
    )
