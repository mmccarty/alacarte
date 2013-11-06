define ['lodash', 'angular-mocks', 'dialogs/select-items-dialog'], (_) ->

  describe 'select items controller', ->
    $rootScope    = null
    ctrl          = null
    modalInstance = null
    model         = null
    scope         = null

    beforeEach module('dashboard-ui.selectItemsDialog')

    beforeEach inject((_$rootScope_, $controller) ->
      $rootScope = _$rootScope_
      scope = $rootScope.$new()
      model = {
        selectedItems: ['stuff'],
        allItems:      ['stuff', 'things', 'whatnot']
      }
      ctrl = $controller('SelectItemsDialog', { $scope: scope, $modalInstance: modalInstance, model: model })
    )

    describe 'initial select conditions', ->

      it 'should accurately reflected provided selected items', ->
        expect(_.pluck(scope.selectedItems, 'name')).toEqual model.selectedItems

      it 'should update all items, removing any selected item', ->
        expect(_.pluck(scope.allItems, 'name')).toEqual ['things', 'whatnot']

      it 'should indicate no items are selected', ->
        expect(scope.selectedItemSelected).toBe false
        expect(scope.allItemSelected).toBe false

    describe 'adding an item to selected items', ->

      it 'should remove item from all items', ->
        expect(scope.allItems.length).toBe 2
        scope.allItemsModel = ['things']
        scope.selectFromAll()
        scope.moveToSelectedItems()
        expect(scope.allItems.length).toBe 1

      it 'should add item to selected items', ->
        expect(scope.selectedItems.length).toBe 1
        scope.allItemsModel = ['things']
        scope.selectFromAll()
        scope.moveToSelectedItems()
        expect(scope.selectedItems.length).toBe 2

      it 'should enable and then disable move to selected arrow', ->
        scope.allItemsModel = ['things']
        scope.selectFromAll()
        expect(scope.allItemSelected).toBe true
        scope.moveToSelectedItems()
        expect(scope.allItemSelected).toBe false

    describe 'removing an item from selected items', ->

      it 'should add item to all items', ->
        expect(scope.allItems.length).toBe 2
        scope.selectedItemsModel = ['stuff']
        scope.selectFromSelected()
        scope.removeFromSelectedItems()
        expect(scope.allItems.length).toBe 3

      it 'should remove item from selected items', ->
        expect(scope.selectedItems.length).toBe 1
        scope.selectedItemsModel = ['stuff']
        scope.selectFromSelected()
        scope.removeFromSelectedItems()
        expect(scope.selectedItems.length).toBe 0

      it 'should enable and then disable move to all arrow', ->
        scope.selectedItemsModel = ['stuff']
        scope.selectFromSelected()
        expect(scope.selectedItemSelected).toBe true
        scope.removeFromSelectedItems()
        expect(scope.selectedItemSelected).toBe false
