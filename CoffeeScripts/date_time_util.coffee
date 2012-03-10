TN.dateToString = (dateString, shortMonth=false) ->
  DAYS_OF_WEEK = [
    "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday",
    "Friday", "Saturday" ]

  SHORT_MONTHS = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
    'Nov', 'Dec' ]

  MONTHS = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December']

  date = TN.decodeDate(dateString)

  month =
    if shortMonth
      SHORT_MONTHS[date.getMonth()]
    else
      MONTHS[date.getMonth()]

  DAYS_OF_WEEK[date.getDay()] + ", " + month + " " + date.getDate()

TN.timeToString = (time) ->
  jsTime = new Date()
  jsTime.setHours(time.slice(0,2))
  jsTime.setMinutes(time.slice(2))

  hour = jsTime.getHours()
  amPM =
    if hour < 12
      'AM'
    else
      'PM'

  formattedHour =
    if hour == 0
      12
    else if hour >= 1 && hour <= 12
      hour
    else
      hour - 12

  minute = jsTime.getMinutes()
  formattedMinute = ''
  unless minute == 0
    formattedMinute = ":#{TN.intWithLeadingZeros(minute, 2)}"

  "#{formattedHour}#{formattedMinute} #{amPM}"

TN.msPerWeek = 7 * 24 * 60 * 60 * 1000
TN.msPerYear = TN.msPerWeek * 52
