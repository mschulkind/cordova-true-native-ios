describe "util", ->
  describe "ellipsizeString", ->
    it "works", ->
      expect(TN.ellipsizeString('foo', 10)).toBe('foo')
      expect(TN.ellipsizeString('foobar', 5)).toBe('fooba...')

  describe "intWithLeadingZeros", ->
    it "works", ->
      expect(TN.intWithLeadingZeros(3, 2)).toBe('03')
      expect(TN.intWithLeadingZeros(7, 3)).toBe('007')
      expect(TN.intWithLeadingZeros(3, 1)).toBe('3')
      expect(TN.intWithLeadingZeros(3234, 3)).toBe('3234')
      expect(TN.intWithLeadingZeros(233, 7)).toBe('0000233')
