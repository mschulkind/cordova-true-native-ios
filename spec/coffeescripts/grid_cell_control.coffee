describe 'GridCell', ->
  beforeEach(->
    spy = spyOn(TN.UI.Component.prototype, 'getProperties')
      .andCallFake(-> spy.mostRecentCall.args[1]?())
  )

  describe 'option values', ->
    optionValueTest = (optionName, optionValues) ->
      it "throws on invalid #{optionName}", ->
        unknownMsg = "Unknown #{optionName}"
        options = {}

        options[optionName] = 'foo'
        expect(-> new TN.GridCell(options)).toThrow(unknownMsg)
        for value in optionValues
          options[optionName] = value
          expect(-> new TN.GridCell(options)).not.toThrow(unknownMsg)

    optionValueTest('growMode', ['none', 'vertical', 'horizontal', 'both'])
    optionValueTest('layoutMode', ['vertical', 'horizontal'])
    optionValueTest('verticalAlign', ['top', 'middle'])
    optionValueTest('inheritViewSizeMode', ['none', 'width', 'height', 'both'])

    it 'has sane defaults', ->
      gridCell = new TN.GridCell

      expect(gridCell.growMode).toBe('none')
      expect(gridCell.layoutMode).toBe('horizontal')

      expect(gridCell.padding).toBe(0)
      expect(gridCell.spacing).toBe(0)

      expect(gridCell.verticalAlign).toBe('top')

    it 'supports custom views', ->
      view = new TN.UI.View
      gridCell = new TN.GridCell(view: view)
      expect(gridCell.view).toBe(view)

    it 'supports fixed height and width', ->
      gridCell = new TN.GridCell(fixedWidth: 12, fixedHeight: 34)
      gridCell.layout()
      expect(gridCell.view.width).toBe(12)
      expect(gridCell.view.height).toBe(34)

    it 'throws on grow && fixed', ->
      expect(-> new TN.GridCell(growMode: 'horizontal', fixedWidth: 4))
        .toThrow()
      expect(-> new TN.GridCell(growMode: 'vertical', fixedHeight: 4))
        .toThrow()
      expect(-> new TN.GridCell(growMode: 'both', fixedHeight: 4))
        .toThrow()
      expect(-> new TN.GridCell(growMode: 'both', fixedWidth: 4))
        .toThrow()
      expect(-> new TN.GridCell(
        growMode: 'both', fixedWidth: 4, fixedHeight: 4)
      ).toThrow()

      expect(-> new TN.GridCell(growMode: 'vertical', fixedWidth: 4))
        .not.toThrow()
      expect(-> new TN.GridCell(growMode: 'horizontal', fixedHeight: 4))
        .not.toThrow()
      expect(-> new TN.GridCell(
        growMode: 'none', fixedWidth: 4, fixedHeight: 4)
      ).not.toThrow()

    it 'throws on inherit && fixed', ->
      expect(-> new TN.GridCell(inheritViewSizeMode: 'width', fixedWidth: 1))
        .toThrow()
      expect(-> new TN.GridCell(inheritViewSizeMode: 'width', fixedHeight: 1))
        .not.toThrow()
      expect(-> new TN.GridCell(inheritViewSizeMode: 'height', fixedHeight: 1))
        .toThrow()
      expect(-> new TN.GridCell(inheritViewSizeMode: 'height', fixedWidth: 1))
        .not.toThrow()
      expect(-> new TN.GridCell(inheritViewSizeMode: 'both')).not.toThrow()
      expect(-> new TN.GridCell(inheritViewSizeMode: 'both', fixedHeight: 1))
        .toThrow()
      expect(-> new TN.GridCell(inheritViewSizeMode: 'both', fixedWidth: 1))
        .toThrow()
      expect(->
        new TN.GridCell(
          inheritViewSizeMode: 'both'
          fixedWidth: 1
          fixedHeight: 1
        )
      ).toThrow()

  describe 'add', ->
    it 'calls layout', ->
      gridCell = new TN.GridCell
      spyOn(gridCell, 'layout')
      gridCell.add(new TN.GridCell)
      expect(gridCell.layout).toHaveBeenCalled()

    it 'calls layout on the root parent on add', ->
      parentCell = new TN.GridCell(fixedWidth: 100, padding: 5)
      childCell = new TN.GridCell(layoutMode: 'vertical')
      parentCell.add(childCell)

      # These add calls are deliberately after adding the child cell to the
      # parent cell. If layout is only called on the child cell on add, the
      # parent cell will not get a chance to resize itself.
      childCell.add(new TN.GridCell(fixedHeight: 10))
      childCell.add(new TN.GridCell(fixedHeight: 20))

      expect(parentCell.view.height).toBe(40)
      expect(childCell.view.height).toBe(30)

    it 'supports cells and views', ->
      gridCell = new TN.GridCell(fixedWidth: 90)
      a = new TN.GridCell(fixedWidth: 20)
      gridCell.add(a)
      b = new TN.UI.View(width: 30, height: 40)
      gridCell.add(b)
      c = new TN.GridCell(growMode: 'horizontal')
      gridCell.add(c)

      expect(gridCell.view.width).toBe(90)
      expect(gridCell.view.left).toBe(0)
      expect(a.view.width).toBe(20)
      expect(a.view.left).toBe(0)
      expect(b.width).toBe(30)
      expect(b.height).toBe(40)
      expect(b.left).toBe(20)
      expect(c.view.width).toBe(40)
      expect(c.view.left).toBe(50)

      b.width = 32
      gridCell.layout()
      expect(c.view.width).toBe(38)

  describe 'fixedKeyForDimension', ->
    it 'works', ->
      gridCell = new TN.GridCell
      expect(gridCell.fixedKeyForDimension('height')).toBe('fixedHeight')
      expect(gridCell.fixedKeyForDimension('width')).toBe('fixedWidth')

    it 'throws on invalid dimension', ->
      gridCell = new TN.GridCell
      expect(-> gridCell.fixedKeyForDimension('height')).not.toThrow()
      expect(-> gridCell.fixedKeyForDimension('width')).not.toThrow()
      expect(-> gridCell.fixedKeyForDimension('foo')).toThrow()
      expect(-> gridCell.fixedKeyForDimension('bar')).toThrow()

  describe 'isDimensionFixed', ->
    it 'works for width and height', ->
      a = new TN.GridCell(fixedWidth: 1)
      expect(a.isDimensionFixed('width')).toBeTruthy()
      expect(a.isDimensionFixed('height')).toBeFalsy()
      b = new TN.GridCell(fixedHeight: 1)
      expect(b.isDimensionFixed('width')).toBeFalsy()
      expect(b.isDimensionFixed('height')).toBeTruthy()
      c = new TN.GridCell(fixedWidth: 1, fixedHeight: 1)
      expect(c.isDimensionFixed('width')).toBeTruthy()
      expect(c.isDimensionFixed('height')).toBeTruthy()
      d = new TN.GridCell()
      expect(d.isDimensionFixed('width')).toBeFalsy()
      expect(d.isDimensionFixed('height')).toBeFalsy()

  describe 'inheritsViewDimension', ->
    it 'works for width and height', ->
      a = new TN.GridCell(inheritViewSizeMode: 'width')
      expect(a.inheritsViewDimension('width')).toBeTruthy()
      expect(a.inheritsViewDimension('height')).toBeFalsy()

      b = new TN.GridCell(inheritViewSizeMode: 'height')
      expect(b.inheritsViewDimension('width')).toBeFalsy()
      expect(b.inheritsViewDimension('height')).toBeTruthy()

      c = new TN.GridCell(inheritViewSizeMode: 'both')
      expect(c.inheritsViewDimension('width')).toBeTruthy()
      expect(c.inheritsViewDimension('height')).toBeTruthy()

      d = new TN.GridCell(inheritViewSizeMode: 'none')
      expect(d.inheritsViewDimension('width')).toBeFalsy()
      expect(d.inheritsViewDimension('height')).toBeFalsy()

  describe 'growsInDimension', ->
    it 'works for width and height', ->
      a = new TN.GridCell(growMode: 'horizontal')
      expect(a.growsInDimension('width')).toBeTruthy()
      expect(a.growsInDimension('height')).toBeFalsy()

      b = new TN.GridCell(growMode: 'vertical')
      expect(b.growsInDimension('width')).toBeFalsy()
      expect(b.growsInDimension('height')).toBeTruthy()

      c = new TN.GridCell(growMode: 'both')
      expect(c.growsInDimension('width')).toBeTruthy()
      expect(c.growsInDimension('height')).toBeTruthy()

      d = new TN.GridCell(growMode: 'none')
      expect(d.growsInDimension('width')).toBeFalsy()
      expect(d.growsInDimension('height')).toBeFalsy()

  describe 'maxNonGrowingChildSizeInDimension', ->
    it 'works for width', ->
      gridCell = new TN.GridCell(fixedWidth: 100)
      gridCell.add(new TN.GridCell(fixedWidth: 10))
      gridCell.add(new TN.GridCell(fixedWidth: 20))
      gridCell.add(new TN.GridCell(
        growMode: 'horizontal'
        view: new TN.UI.View(width: 30)
      ))
      expect(gridCell.maxNonGrowingChildSizeInDimension('width')).toBe(20)

    it 'works for height', ->
      gridCell = new TN.GridCell(fixedHeight: 100)
      gridCell.add(new TN.GridCell(fixedHeight: 30))
      gridCell.add(new TN.GridCell(fixedHeight: 42))
      gridCell.add(new TN.GridCell(
        growMode: 'vertical'
        view: new TN.UI.View(height: 80)
      ))
      expect(gridCell.maxNonGrowingChildSizeInDimension('height')).toBe(42)

  describe 'numChildrenGrowInDimension', ->
    it 'works for width and height', ->
      gridCell = new TN.GridCell(fixedWidth: 1, fixedHeight: 1)
      gridCell.add(new TN.GridCell(growMode: 'both'))
      gridCell.add(new TN.GridCell(growMode: 'both'))
      gridCell.add(new TN.GridCell)
      gridCell.add(new TN.GridCell(growMode: 'vertical'))
      gridCell.add(new TN.GridCell(growMode: 'vertical'))
      gridCell.add(new TN.GridCell(growMode: 'horizontal'))
      gridCell.add(new TN.GridCell)

      expect(gridCell.numChildrenGrowInDimension('width')).toBe(3)
      expect(gridCell.numChildrenGrowInDimension('height')).toBe(4)

  describe 'layoutDimension', ->
    worksForTest = (layoutMode, layoutDimension, otherDimension) ->
      it "works for #{layoutMode}", ->
        gridCell = new TN.GridCell(layoutMode: layoutMode)
        spyOn(gridCell, 'layoutOtherDimension')
        spyOn(gridCell, 'layoutLayoutDimension')

        gridCell.layoutDimension(layoutDimension)
        expect(gridCell.layoutLayoutDimension).toHaveBeenCalled()
        expect(gridCell.layoutOtherDimension).not.toHaveBeenCalled()

        gridCell.layoutLayoutDimension.reset()

        gridCell.layoutDimension(otherDimension)
        expect(gridCell.layoutLayoutDimension).not.toHaveBeenCalled()
        expect(gridCell.layoutOtherDimension).toHaveBeenCalled()

    worksForTest('vertical', 'height', 'width')
    worksForTest('horizontal', 'width', 'height')

    it 'throws on unknown', ->
      expect(-> (new TN.GridCell).layoutDimension('foo')).toThrow()

  describe 'layout', ->
    it 'calls fires a layout event', ->
      parentCell = new TN.GridCell
      childCell = new TN.GridCell
      parentCell.add(childCell)

      parentCallback =
        parentCell.addEventListener('layout', jasmine.createSpy())
      childCallback =
        childCell.addEventListener('layout', jasmine.createSpy())
      parentCell.layout()
      expect(parentCallback).toHaveBeenCalled()
      expect(childCallback).toHaveBeenCalled()

    it 'does not crash with no children', ->
      (new TN.GridCell).layout()

    it 'updates sizes first', ->
      @parentCell = new TN.GridCell
      @a = new TN.UI.View(width: 20)
      @parentCell.add(@a)
      @b = new TN.UI.View(width: 10, height: 15)
      @parentCell.add(@b)

      @childCell = new TN.GridCell
      @parentCell.add(@childCell)
      @c = new TN.UI.View
      @childCell.add(@c)

      expect(@parentCell.view.width).toBe(30)
      expect(@parentCell.view.height).toBe(15)
      expect(@a.height).toBe(0)
      expect(@c.width).toBe(0)

      # getProperties is already spied on by the top-level beforeEach, so we
      # have to unspy the prototype function first.
      TN.UI.Component::getProperties = TN.UI.Component::getProperties.plan

      # All of these fakes use afterDelay to ensure that layout actually waits
      # for the properties to come back. If we did not use afterDelay here, the
      # fakes would be called before returning from getProperties and would
      # mask and bug if layout did not wait.
      @spyA = spyOn(@a, 'getProperties').andCallFake(=>
        TN.afterDelay(50, =>
          @a.height = 8
          @spyA.mostRecentCall.args[1]()
        )
      )
      @spyB = spyOn(@b, 'getProperties').andCallFake(=>
        TN.afterDelay(50, =>
          @b.width = 30
          @b.height = 25
          @spyB.mostRecentCall.args[1]()
        )
      )
      @spyC = spyOn(@c, 'getProperties').andCallFake(=>
        TN.afterDelay(50, =>
          @c.width = 5
          @spyC.mostRecentCall.args[1]()
        )
      )

      @parentCellLayoutListener =
        @parentCell.addEventListener('layout', jasmine.createSpy())
      @parentCell.layout()

      waitsFor =>
        @parentCellLayoutListener.callCount != 0

      runs =>
        expect(@parentCell.view.width).toBe(55)
        expect(@parentCell.view.height).toBe(25)
        expect(@spyA).toHaveBeenCalled()
        expect(@a.width).toBe(20)
        expect(@a.height).toBe(8)
        expect(@spyB).toHaveBeenCalled()
        expect(@b.width).toBe(30)
        expect(@b.height).toBe(25)
        expect(@childCell.view.width).toBe(5)
        expect(@childCell.view.height).toBe(0)
        expect(@spyC).toHaveBeenCalled()
        expect(@c.width).toBe(5)
        expect(@c.height).toBe(0)

    it 'inherits view size', ->
      parentView = new TN.UI.View(width: 5, height: 6)
      parentCell = new TN.GridCell(
        inheritViewSizeMode: 'both'
        view: parentView
      )

      expect(parentCell.fixedWidth).toBe(5)
      expect(parentCell.view.width).toBe(5)
      expect(parentCell.fixedHeight).toBe(6)
      expect(parentCell.view.height).toBe(6)

      parentView.width = 7
      parentView.height = 8

      childCell = new TN.GridCell(growMode: 'both')
      parentCell.add(childCell)

      expect(parentCell.fixedWidth).toBe(7)
      expect(parentCell.view.width).toBe(7)
      expect(parentCell.fixedHeight).toBe(8)
      expect(parentCell.view.height).toBe(8)
      expect(childCell.view.width).toBe(7)
      expect(childCell.view.height).toBe(8)

    it 'inherits view width', ->
      parentCell = new TN.GridCell(inheritViewSizeMode: 'width')
      parentCell.view.width = 12
      childCell = new TN.GridCell(growMode: 'horizontal')
      parentCell.add(childCell)

      expect(parentCell.fixedWidth).toBe(12)
      expect(childCell.view.width).toBe(12)

    it 'inherits view height', ->
      parentCell = new TN.GridCell(inheritViewSizeMode: 'height')
      parentCell.view.height = 14
      childCell = new TN.GridCell(growMode: 'vertical')
      parentCell.add(childCell)

      expect(parentCell.fixedHeight).toBe(14)
      expect(childCell.view.height).toBe(14)

  describe 'fixed width and height', ->
    it 'does not shrink fixed width if children are smaller', ->
      gridCell = new TN.GridCell(fixedWidth: 100)
      a = new TN.GridCell(fixedWidth: 20)
      gridCell.add(a)
      b = new TN.GridCell(fixedWidth: 40)
      gridCell.add(b)

      expect(gridCell.view.width).toBe(100)

    it 'it throws if child height exceeds fixed height', ->
      gridCell = new TN.GridCell(fixedHeight: 10, padding: 2)
      a = new TN.GridCell(fixedHeight: 6)
      expect(-> gridCell.add(a)).not.toThrow()
      b = new TN.GridCell(fixedHeight: 7)
      expect(-> gridCell.add(b)).toThrow()

    it 'it throws if children width exceeds fixed width', ->
      gridCell = new TN.GridCell(fixedWidth: 50, spacing: 5, padding: 10)
      a = new TN.GridCell(fixedWidth: 20)
      expect(-> gridCell.add(a)).not.toThrow()
      b = new TN.GridCell(fixedWidth: 6)
      expect(-> gridCell.add(b)).toThrow()

  describe 'horizontal layout', ->
    describe 'has children, but no grandchildren', ->
      it 'supports padding', ->
        gridCell = new TN.GridCell(padding: 10)
        a = new TN.GridCell(fixedWidth: 20, fixedHeight: 10)
        gridCell.add(a)
        b = new TN.GridCell(fixedWidth: 40, fixedHeight: 20)
        gridCell.add(b)

        expect(a.view.left).toBe(10)
        expect(a.view.top).toBe(10)
        expect(b.view.left).toBe(30)
        expect(b.view.top).toBe(10)
        expect(gridCell.view.width).toBe(80)
        expect(gridCell.view.height).toBe(40)

      it 'supports spacing', ->
        gridCell = new TN.GridCell(spacing: 10)
        a = new TN.GridCell(fixedWidth: 20)
        gridCell.add(a)
        b = new TN.GridCell(fixedWidth: 40)
        gridCell.add(b)

        expect(a.view.left).toBe(0)
        expect(b.view.left).toBe(30)
        expect(gridCell.view.width).toBe(70)

      it 'sizes the other dimension by the maximum child size', ->
        gridCell = new TN.GridCell
        a = new TN.GridCell(fixedHeight: 20)
        gridCell.add(a)
        b = new TN.GridCell(fixedHeight: 40)
        gridCell.add(b)

        expect(gridCell.view.height).toBe(40)

      describe 'vertical align', ->
        it 'supports top', ->
          gridCell = new TN.GridCell(verticalAlign:'top')
          a = new TN.GridCell(fixedHeight: 20)
          gridCell.add(a)
          b = new TN.GridCell(fixedHeight: 40)
          gridCell.add(b)

          expect(a.view.top).toBe(0)
          expect(b.view.top).toBe(0)

        it 'supports middle', ->
          gridCell = new TN.GridCell(verticalAlign: 'middle', padding: 5)
          a = new TN.GridCell(fixedHeight: 20)
          gridCell.add(a)
          b = new TN.GridCell(fixedHeight: 40)
          gridCell.add(b)

          expect(a.view.top).toBe(15)
          expect(b.view.top).toBe(5)

        it 'supports middle with a fixed height parent', ->
          gridCell = new TN.GridCell(
            verticalAlign: 'middle'
            fixedHeight: 100
            padding: 10
          )
          a = new TN.GridCell(fixedHeight: 20)
          gridCell.add(a)
          b = new TN.GridCell(fixedHeight: 40)
          gridCell.add(b)

          expect(a.view.top).toBe(40)
          expect(b.view.top).toBe(30)

      describe 'vertical growth', ->
        it 'works', ->
          gridCell = new TN.GridCell(verticalAlign: 'middle')
          a = new TN.GridCell(growMode: 'vertical')
          gridCell.add(a)
          b = new TN.GridCell(fixedHeight: 40)
          gridCell.add(b)
          c = new TN.GridCell(fixedHeight: 20)
          gridCell.add(c)

          expect(a.view.top).toBe(0)
          expect(a.view.height).toBe(40)
          expect(b.view.top).toBe(0)
          expect(b.view.height).toBe(40)
          expect(c.view.top).toBe(10)
          expect(c.view.height).toBe(20)

        it 'works with a fixed height parent', ->
          gridCell = new TN.GridCell(fixedHeight: 60)
          a = new TN.GridCell(growMode: 'vertical')
          gridCell.add(a)
          b = new TN.GridCell(fixedHeight: 40)
          gridCell.add(b)

          expect(a.view.top).toBe(0)
          expect(a.view.height).toBe(60)
          expect(b.view.top).toBe(0)
          expect(b.view.height).toBe(40)

        it 'works when a growing child starts taller than the cell hiehgt', ->
          gridCell = new TN.GridCell(fixedHeight: 100)

          gridCell.add(new TN.GridCell(fixedHeight: 20))
          gridCell.add(new TN.GridCell(fixedHeight: 40))
          gridCell.add(new TN.GridCell(
            view: new TN.UI.View(height: 120)
            growMode: 'vertical'
          ))
        
      it 'grows vertically and horizontally', ->
        gridCell = new TN.GridCell(verticalAlign: 'middle', fixedWidth: 50)
        a = new TN.GridCell(growMode: 'both')
        gridCell.add(a)
        b = new TN.GridCell(fixedHeight: 40, fixedWidth: 40)
        gridCell.add(b)
        c = new TN.GridCell(growMode: 'vertical', fixedWidth: 2)
        gridCell.add(c)
        d = new TN.GridCell(fixedHeight: 10, fixedWidth: 3)
        gridCell.add(d)

        expect(gridCell.view.width).toBe(50)
        expect(a.view.height).toBe(40)
        expect(a.view.left).toBe(0)
        expect(b.view.height).toBe(40)
        expect(b.view.left).toBe(5)
        expect(c.view.height).toBe(40)
        expect(c.view.left).toBe(45)
        expect(d.view.height).toBe(10)
        expect(d.view.left).toBe(47)

      describe 'horizontal growing', ->
        it 'throws if parent does not have fixed width', ->
          gridCell = new TN.GridCell

          expect(-> gridCell.add(new TN.GridCell(growMode: 'horizontal')))
            .toThrow()
          gridCell.fixedWidth = 10
          expect(-> gridCell.add(new TN.GridCell(growMode: 'horizontal')))
            .not.toThrow()

        it 'grows one child', ->
          gridCell = new TN.GridCell(fixedWidth: 100)
          a = new TN.GridCell(fixedWidth: 20)
          gridCell.add(a)
          b = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(b)

          expect(gridCell.view.width).toBe(100)
          expect(a.view.width).toBe(20)
          expect(a.view.left).toBe(0)
          expect(b.view.width).toBe(80)
          expect(b.view.left).toBe(20)

        it 'grows when both specified', ->
          gridCell = new TN.GridCell(fixedWidth: 100)
          a = new TN.GridCell(growMode: 'both')
          gridCell.add(a)
          expect(a.view.width).toBe(100)

        it 'grows two children', ->
          gridCell = new TN.GridCell(fixedWidth: 100)
          a = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(a)

          expect(a.view.width).toBe(100)

          b = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(b)

          expect(gridCell.view.width).toBe(100)
          expect(a.view.width).toBe(50)
          expect(a.view.left).toBe(0)
          expect(b.view.width).toBe(50)
          expect(b.view.left).toBe(50)

        it 'grows two children with spacing and padding', ->
          gridCell = new TN.GridCell(fixedWidth: 100, spacing: 10, padding: 20)
          a = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(a)

          expect(a.view.width).toBe(60)

          b = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(b)

          expect(gridCell.view.width).toBe(100)
          expect(a.view.width).toBe(25)
          expect(a.view.left).toBe(20)
          expect(b.view.width).toBe(25)
          expect(b.view.left).toBe(55)

        it 'grows two children with spacing', ->
          gridCell = new TN.GridCell(fixedWidth: 100, spacing: 1)
          a = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(a)

          expect(a.view.width).toBe(100)

          b = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(b)

          expect(gridCell.view.width).toBe(100)
          expect(a.view.width).toBe(49)
          expect(a.view.left).toBe(0)
          expect(b.view.width).toBe(50)
          expect(b.view.left).toBe(50)

        it 'handles rounding errors', ->
          gridCell = new TN.GridCell(fixedWidth: 100)
          a = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(a)
          b = new TN.GridCell(fixedWidth: 1)
          gridCell.add(b)
          c = new TN.GridCell(growMode: 'horizontal')
          gridCell.add(c)

          expect(gridCell.view.width).toBe(100)
          expect(a.view.width).toBe(49)
          expect(a.view.left).toBe(0)
          expect(b.view.width).toBe(1)
          expect(b.view.left).toBe(49)
          expect(c.view.width).toBe(50)
          expect(c.view.left).toBe(50)

    describe 'has grandchildren', ->
      it 'generally works (no growing)', ->
        # Rough layout of cells:
        # [a [b c] d]
        parentCell = new TN.GridCell(
          padding: 5
          spacing: 10
          verticalAlign: 'middle'
        )
        a = new TN.GridCell(fixedWidth: 8)
        parentCell.add(a)

        childCell = new TN.GridCell(padding: 1, spacing: 2)
        b = new TN.GridCell(fixedHeight: 40, fixedWidth: 5)
        childCell.add(b)
        c = new TN.GridCell(fixedHeight: 20, fixedWidth: 10)
        childCell.add(c)
        parentCell.add(childCell)

        d = new TN.GridCell(fixedHeight: 50, fixedWidth: 15)
        parentCell.add(d)

        expect(parentCell.view.height).toBe(60)
        expect(parentCell.view.width).toBe(72)
        expect(a.view.height).toBe(0)
        expect(a.view.width).toBe(8)
        expect(a.view.top).toBe(30)
        expect(a.view.left).toBe(5)
        
        expect(childCell.view.height).toBe(42)
        expect(childCell.view.width).toBe(19)
        expect(b.view.height).toBe(40)
        expect(b.view.width).toBe(5)
        expect(b.view.top).toBe(1)
        expect(b.view.left).toBe(1)
        expect(c.view.height).toBe(20)
        expect(c.view.width).toBe(10)
        expect(c.view.top).toBe(1)
        expect(c.view.left).toBe(8)

        expect(d.view.height).toBe(50)
        expect(d.view.width).toBe(15)
        expect(d.view.top).toBe(5)
        expect(d.view.left).toBe(52)

      it 'sets fixed size and view size on growing with rounding correction', ->
        gridCell = new TN.GridCell(fixedWidth: 50)
        a = new TN.GridCell(growMode: 'horizontal')
        gridCell.add(a)
        b = new TN.GridCell(fixedWidth: 1)
        gridCell.add(b)
        c = new TN.GridCell(growMode: 'horizontal')
        gridCell.add(c)

        expect(a.view.width).toBe(24)
        expect(a.fixedWidth).toBe(24)
        expect(c.view.width).toBe(25)
        expect(c.fixedWidth).toBe(25)

      it 'grows one grandchild', ->
        # Rough layout of cells:
        # [a [b c d] e]
        parentCell = new TN.GridCell(fixedWidth: 80)
        a = new TN.GridCell(fixedWidth: 10)
        parentCell.add(a)

        childCell = new TN.GridCell(growMode: 'horizontal')
        parentCell.add(childCell)
        b = new TN.GridCell(fixedWidth: 5, fixedHeight: 20)
        childCell.add(b)
        c = new TN.GridCell(growMode: 'both')
        childCell.add(c)
        d = new TN.GridCell(fixedWidth: 20, fixedHeight: 10)
        childCell.add(d)

        e = new TN.GridCell(fixedWidth: 15)
        parentCell.add(e)

        expect(parentCell.view.width).toBe(80)
        expect(parentCell.view.height).toBe(20)
        expect(parentCell.view.left).toBe(0)
        expect(a.view.width).toBe(10)
        expect(a.view.left).toBe(0)

        expect(childCell.view.width).toBe(55)
        expect(childCell.view.height).toBe(20)
        expect(childCell.view.left).toBe(10)
        expect(b.view.width).toBe(5)
        expect(b.view.left).toBe(0)
        expect(c.view.width).toBe(30)
        expect(c.view.height).toBe(20)
        expect(c.view.left).toBe(5)
        expect(d.view.width).toBe(20)
        expect(d.view.left).toBe(35)

        expect(e.view.width).toBe(15)
        expect(e.view.left).toBe(65)

      it 'grows three grandchildren', ->
        # Rough layout of cells:
        # [ [a b] [c d e] ]
        parentCell = new TN.GridCell(fixedWidth: 100)

        childCellA = new TN.GridCell(growMode: 'horizontal', spacing: 8)
        parentCell.add(childCellA)
        a = new TN.GridCell(fixedWidth: 10)
        childCellA.add(a)
        b = new TN.GridCell(growMode: 'horizontal')
        childCellA.add(b)

        expect(childCellA.view.width).toBe(100)
        expect(a.view.width).toBe(10)
        expect(b.view.width).toBe(82)

        childCellB = new TN.GridCell(growMode: 'horizontal', padding: 2)
        parentCell.add(childCellB)
        c = new TN.GridCell(growMode: 'horizontal')
        childCellB.add(c)
        d = new TN.GridCell(fixedWidth: 5)
        childCellB.add(d)
        e = new TN.GridCell(growMode: 'horizontal')
        childCellB.add(e)

        expect(parentCell.view.width).toBe(100)
        expect(parentCell.view.left).toBe(0)
        expect(childCellA.view.width).toBe(50)
        expect(childCellA.view.left).toBe(0)
        expect(a.view.width).toBe(10)
        expect(a.view.left).toBe(0)
        expect(b.view.width).toBe(32)
        expect(b.view.left).toBe(18)
        expect(childCellB.view.width).toBe(50)
        expect(childCellB.view.left).toBe(50)
        expect(c.view.width).toBe(20)
        expect(c.view.left).toBe(2)
        expect(d.view.width).toBe(5)
        expect(d.view.left).toBe(22)
        expect(e.view.width).toBe(21)
        expect(e.view.left).toBe(27)

      it 'grows grandchildren with layoutMode != growMode', ->
        # Rough layout of cells:
        # [ [ a ] ]
        # [ [ b ] ]
        
        parentCell = new TN.GridCell(fixedWidth: 100)

        childCell = new TN.GridCell(
          growMode: 'horizontal'
          layoutMode: 'vertical'
        )
        parentCell.add(childCell)

        a = new TN.GridCell(
          growMode: 'horizontal'
          view: new TN.UI.View(width: 200)
        )
        childCell.add(a)

        b = new TN.GridCell(
          growMode: 'horizontal'
          view: new TN.UI.View(width: 10)
        )
        childCell.add(b)

        expect(parentCell.view.width).toBe(100)
        expect(childCell.view.width).toBe(100)
        expect(a.view.width).toBe(100)
        expect(b.view.width).toBe(100)
