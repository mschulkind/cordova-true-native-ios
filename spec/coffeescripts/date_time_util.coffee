describe "dateToString", ->
  it "works for days of week", ->
    expect(TN.dateToString('2011-08-21')).toBe('Sunday, August 21')
    expect(TN.dateToString('2011-08-22')).toBe('Monday, August 22')
    expect(TN.dateToString('2011-08-23')).toBe('Tuesday, August 23')
    expect(TN.dateToString('2011-08-24')).toBe('Wednesday, August 24')
    expect(TN.dateToString('2011-08-25')).toBe('Thursday, August 25')
    expect(TN.dateToString('2011-08-26')).toBe('Friday, August 26')
    expect(TN.dateToString('2011-08-27')).toBe('Saturday, August 27')

  it "works for short month names", ->
    expect(TN.dateToString('2004-01-01', true)).toBe('Thursday, Jan 1')
    expect(TN.dateToString('2004-02-01', true)).toBe('Sunday, Feb 1')
    expect(TN.dateToString('2004-03-01', true)).toBe('Monday, Mar 1')
    expect(TN.dateToString('2004-04-01', true)).toBe('Thursday, Apr 1')
    expect(TN.dateToString('2004-05-01', true)).toBe('Saturday, May 1')
    expect(TN.dateToString('2004-06-01', true)).toBe('Tuesday, Jun 1')
    expect(TN.dateToString('2004-07-01', true)).toBe('Thursday, Jul 1')
    expect(TN.dateToString('2004-08-01', true)).toBe('Sunday, Aug 1')
    expect(TN.dateToString('2004-09-01', true)).toBe('Wednesday, Sep 1')
    expect(TN.dateToString('2004-10-01', true)).toBe('Friday, Oct 1')
    expect(TN.dateToString('2004-11-01', true)).toBe('Monday, Nov 1')
    expect(TN.dateToString('2004-12-01', true)).toBe('Wednesday, Dec 1')

  it "works for full month names", ->
    expect(TN.dateToString('2004-01-01')).toBe('Thursday, January 1')
    expect(TN.dateToString('2004-02-01')).toBe('Sunday, February 1')
    expect(TN.dateToString('2004-03-01')).toBe('Monday, March 1')
    expect(TN.dateToString('2004-04-01')).toBe('Thursday, April 1')
    expect(TN.dateToString('2004-05-01')).toBe('Saturday, May 1')
    expect(TN.dateToString('2004-06-01')).toBe('Tuesday, June 1')
    expect(TN.dateToString('2004-07-01')).toBe('Thursday, July 1')
    expect(TN.dateToString('2004-08-01')).toBe('Sunday, August 1')
    expect(TN.dateToString('2004-09-01')).toBe('Wednesday, September 1')
    expect(TN.dateToString('2004-10-01')).toBe('Friday, October 1')
    expect(TN.dateToString('2004-11-01')).toBe('Monday, November 1')
    expect(TN.dateToString('2004-12-01')).toBe('Wednesday, December 1')

describe "timeToString", ->
  it "works", ->
    expect(TN.timeToString('0000')).toBe('12 AM')
    expect(TN.timeToString('0022')).toBe('12:22 AM')
    expect(TN.timeToString('0427')).toBe('4:27 AM')
    expect(TN.timeToString('1112')).toBe('11:12 AM')
    expect(TN.timeToString('1202')).toBe('12:02 PM')
    expect(TN.timeToString('1607')).toBe('4:07 PM')
    expect(TN.timeToString('1600')).toBe('4 PM')
    expect(TN.timeToString('2359')).toBe('11:59 PM')
