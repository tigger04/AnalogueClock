# Übersicht widget for Analogue Clock
# Tadhg Paul https://tigger.dev

options =
  pos:
    x: "left: 35%"
    y: "bottom: 20%"
  sizePercent: 30 # width/height of the clock as % of screen width
  size: 512 # fallback size in px (calculated dynamically)
  scale: 1  # for retina displays set to 2
  fontSize: 48   # in px
  secPtr:
    color: "rgba(209,97,143,35%)" # css color string
    width: 2     # in px
    lengthPercent: 100 # length as % of clock RADIUS
    length: 230  # calculated dynamically
  minPtr:
    color: "rgb(35%,45%,60%, 10%)" # css color string
    width: 16     # in px
    lengthPercent: 58 # length as % of clock RADIUS
    length: 184   # calculated dynamically
  hrPtr:
    color: "rgb(40%,40%,50%, 10%)" # css color string
    width: 23     # in px
    lengthPercent: 35 # length as % of clock RADIUS
    length: 128   # calculated dynamically
  markerOffset: 4 # offset from the border of the clock in px
  majorMarker:
    color: "rgba(80%, 80%, 80%, 50%)" # css color string for hour markers
    width: 8 # in px
    lengthPercent: 8 # length as % of clock diameter
    length: 60    # calculated dynamically
  minorMarker:
    color: "rgba(80%, 80%, 80%, 50%)" # css color string for hour markers
    width: 2      # in px
    lengthPercent: 2   # length as % of clock diameter
    length: 40    # calculated dynamically
  intervalLength: 30  # interval between the transition triggers in seconds
  backgroundBlur: 0 # circular blur area amount in px, set to 0 to disable
  disc:
    sizePercent: 96 # disc size as % of overall clock size
    color: "rgba(0, 0, 0, 15%)" # disc background color
    borderWidth: 0 # border width in px  
    borderColor: "rgba(0,0,0,0%)" # disc background color
    blur: 5 # disc blur amount in px, set to 0 to disable
  dateCenter:
    enabled: true # show date in center
    fontSize: 44 # font size in px
    color: "rgba(0%, 0%, 20%, 80%)" # text color
    backgroundColor: "rgba(0, 0, 0, 45%)" # background circle color
    borderColor: "rgba(255, 255, 255, 20%)" # border color
    borderWidth: 0 # border width in px
    discSizePercent: 15 # size of center disc as % of clock size
    fontFamily: "monospace" # font family
    fontWeight: 300 # font weight
    textShadow: "1px 1px 4px rgba(100%, 100%, 100%, 40%)" # text shadow for legibility 
    textStroke: 0 # text stroke width in px (0 to disable)
    textStrokeColor: "rgba(0, 0, 0, 0.8)" # text stroke color
    blur: 5
  dayOnMinute:
    enabled: true # show day of week on minute hand
    fontSize: 16 # font size in px
    color: "rgba(0%, 0%, 0%, 80%)" # text color
    backgroundColor: "rgba(0, 0, 0, 0%)" # background color (more translucent)
    borderRadius: 8 # border radius in px
    padding: 4 # padding in px
    offsetPercent: 60 # position along minute hand as % from center
    fontFamily: "monospace" # font family
    fontWeight: 500 # font weight
    textShadow: "2px 2px 4px rgba(100%, 100%, 100%, 60%)" # text shadow for legibility
    textStroke: 0 # text stroke width in px (0 to disable)
    textStrokeColor: "rgba(0, 0, 0, 80%)" # text stroke color
    allCaps: true # display day name in all capitals
    stretchFactor: 1.2 # horizontal stretch factor (1.0 = normal, >1.0 = wider, <1.0 = narrower)
    letterSpacing: 10 # letter spacing in px (0 = normal, positive = wider spacing, negative = tighter)
  monthOnHour:
    enabled: true # show month on hour hand
    fontSize: 20 # font size in px
    color: "rgba(0%, 0%, 20%, 60%)" # text color
    backgroundColor: "rgba(0, 0, 0, 0%)" # background color (more translucent)
    borderRadius: 0 # border radius in px
    padding: 4 # padding in px
    offsetPercent: 60 # position along hour hand as % from center
    fontFamily: "monospace" # font family
    fontWeight: 500 # font weight
    textShadow: "2px 2px 4px rgba(100%, 100%, 100%, 60%)" # text shadow for legibility
    textStroke: 0 # text stroke width in px (0 to disable)
    textStrokeColor: "rgba(0, 0, 0, 80%)" # text stroke color
    allCaps: true # display month name in all capitals
    stretchFactor: 1.1 # horizontal stretch factor (1.0 = normal, >1.0 = wider, <1.0 = narrower)
    letterSpacing: 2 # letter spacing in px (0 = normal, positive = wider spacing, negative = tighter)

refreshFrequency: "30s" # change this as well when changing the intervalLength

# End of styling options

render: (_) -> """
<div class="clock">
  <div class="blur-area"></div>
  <div class="disc"></div>
  <div class="markers"></div>
  <div class="halfDisp">am</div>
  <div class="hrPtr">
    <div class="monthLabel"></div>
  </div>
  <div class="minPtr">
    <div class="dayLabel"></div>
  </div>
  <div class="secPtr"></div>
  <div class="dateCenter">
    <div class="dateText"></div>
  </div>
</div>
"""

afterRender: (domEl) ->
  # Calculate actual size based on viewport width
  options.size = window.innerWidth * options.sizePercent / 100
  
  # Calculate pointer lengths based on clock diameter
  options.secPtr.length = options.size * options.secPtr.lengthPercent / 100
  options.minPtr.length = options.size * options.minPtr.lengthPercent / 100
  options.hrPtr.length = options.size * options.hrPtr.lengthPercent / 100
  
  # Calculate marker lengths based on clock diameter
  options.majorMarker.length = options.size * options.majorMarker.lengthPercent / 100
  options.minorMarker.length = options.size * options.minorMarker.lengthPercent / 100
  
  # Initialize the markers (I just wanted to keep the render function small and tidy)
  markers = $(domEl).find('.markers')
  for i in [0...12]
    for j in [0...5]
      id = ""
      cls = ""
      if j is 0
        id = i+1
        cls = "major"
      else
        id = (i+1)+"_"+j
        cls = "minor"
      rotation = -60 + 6 * (i * 5 + j)
      markers.append('<div id="'+id+'" class="'+cls+'" style="transform: rotate('+rotation+'deg);"></div>')
  
  # Update element styles with calculated size
  @updateElementStyles(domEl)
  
  # Prevent blocking of the clock for the refresh duration after widget refresh
  setTimeout(@refresh)

updateElementStyles: (domEl) ->
  div = $(domEl)
  size = options.size * options.scale
  discSize = size * options.disc.sizePercent / 100
  
  # Ensure click-through for entire widget
  div.css('pointer-events', 'none')
  
  # Update circular blur area styling
  blurAreaStyles = 
    width: "#{size}px"
    height: "#{size}px"
    top: "0px"
    left: "0px"
  
  if options.backgroundBlur > 0
    blurAreaStyles['-webkit-backdrop-filter'] = "blur(#{options.backgroundBlur}px)"
    blurAreaStyles['backdrop-filter'] = "blur(#{options.backgroundBlur}px)"
  
  div.find('.blur-area').css(blurAreaStyles)
  
  # Update disc styling
  discStyles = 
    width: "#{discSize}px"
    height: "#{discSize}px"
    top: "#{(size - discSize) / 2}px"
    left: "#{(size - discSize) / 2}px"
    'background-color': options.disc.color
    'box-sizing': 'border-box'
  
  # Only add border and shadow if there's actually a border or visible disc
  if options.disc.borderWidth > 0
    discStyles['border-width'] = "#{options.disc.borderWidth * options.scale}px"
    discStyles['border-color'] = options.disc.borderColor
    discStyles['border-style'] = 'solid'
  else
    discStyles['border'] = 'none'
  
  # Only add box-shadow if disc is visible
  if options.disc.color != "rgba(0, 0, 0, 0%)" and options.disc.color != "transparent"
    discStyles['box-shadow'] = "0px 0px #{10 * options.scale}px rgba(0,0,0,0.25)"
  else
    discStyles['box-shadow'] = 'none'
  
  if options.disc.blur > 0
    discStyles['-webkit-backdrop-filter'] = "blur(#{options.disc.blur}px)"
    discStyles['backdrop-filter'] = "blur(#{options.disc.blur}px)"
  
  div.find('.disc').css(discStyles)
  
  # Recalculate pointer lengths based on current size
  secLength = options.size * options.secPtr.lengthPercent / 100 * options.scale
  minLength = options.size * options.minPtr.lengthPercent / 100 * options.scale
  hrLength = options.size * options.hrPtr.lengthPercent / 100 * options.scale
  
  # Update pointer positions
  div.find('.secPtr').css
    top: "#{size / 2 - options.secPtr.width * options.scale / 2}px"
    left: "#{size / 2 - options.secPtr.width / 2 * options.scale}px"
    width: "#{secLength}px"
    height: "#{options.secPtr.width * options.scale}px"
    'transform-origin': "#{options.secPtr.width / 2 * options.scale}px 50%"
  
  div.find('.minPtr').css
    top: "#{size / 2 - options.minPtr.width * options.scale / 2}px"
    left: "#{size / 2 - options.minPtr.width / 2 * options.scale}px"
    width: "#{minLength}px"
    height: "#{options.minPtr.width * options.scale}px"
    'transform-origin': "#{options.minPtr.width / 2 * options.scale}px 50%"
  
  div.find('.hrPtr').css
    top: "#{size / 2 - options.hrPtr.width * options.scale / 2}px"
    left: "#{size / 2 - options.hrPtr.width / 2 * options.scale}px"
    width: "#{hrLength}px"
    height: "#{options.hrPtr.width * options.scale}px"
    'transform-origin': "#{options.hrPtr.width / 2 * options.scale}px 50%"
  
  div.find('.halfDisp').css
    top: "#{size * 0.6}px"
    left: "#{size * 0.6}px"
    padding: "0px #{10 * options.scale}px"
    'font-size': "#{options.fontSize * options.scale}px"
  
  # Update date center styling
  if options.dateCenter.enabled
    dateCenterSize = size * options.dateCenter.discSizePercent / 100
    dateCenterStyles = 
      width: "#{dateCenterSize}px"
      height: "#{dateCenterSize}px"
      top: "#{(size - dateCenterSize) / 2}px"
      left: "#{(size - dateCenterSize) / 2}px"
      'background-color': options.dateCenter.backgroundColor
      'border-width': "#{options.dateCenter.borderWidth * options.scale}px"
      'border-color': options.dateCenter.borderColor
      'border-radius': "50%"
      'border-style': 'solid'
      'display': 'flex'
      'align-items': 'center'
      'justify-content': 'center'
    
    # Add blur if enabled
    if options.dateCenter.blur > 0
      dateCenterStyles['-webkit-backdrop-filter'] = "blur(#{options.dateCenter.blur}px)"
      dateCenterStyles['backdrop-filter'] = "blur(#{options.dateCenter.blur}px)"
    
    div.find('.dateCenter').css(dateCenterStyles)
    
    dateTextStyles =
      'font-size': "#{options.dateCenter.fontSize * options.scale}px"
      'color': options.dateCenter.color
      'font-family': options.dateCenter.fontFamily
      'font-weight': options.dateCenter.fontWeight
      'text-align': 'center'
      'line-height': '1'
      'text-shadow': options.dateCenter.textShadow
    
    # Add text stroke if enabled
    if options.dateCenter.textStroke > 0
      dateTextStyles['-webkit-text-stroke'] = "#{options.dateCenter.textStroke * options.scale}px #{options.dateCenter.textStrokeColor}"
    
    div.find('.dateText').css(dateTextStyles)
  else
    div.find('.dateCenter').css('display', 'none')
  
  # Update day label on minute hand
  if options.dayOnMinute.enabled
    dayOffset = minLength * options.dayOnMinute.offsetPercent / 100
    labelWidth = 80
    labelHeight = options.dayOnMinute.fontSize * options.scale + (options.dayOnMinute.padding * options.scale * 2)
    dayLabelStyles = 
      position: 'absolute'
      left: "#{dayOffset - labelWidth / 2}px" # center horizontally on the offset position
      top: "#{-labelHeight / 4}px" # slight adjustment above center
      width: "#{labelWidth}px"
      'font-size': "#{options.dayOnMinute.fontSize * options.scale}px"
      'color': options.dayOnMinute.color
      'background-color': options.dayOnMinute.backgroundColor
      'border-radius': "#{options.dayOnMinute.borderRadius * options.scale}px"
      'padding': "#{options.dayOnMinute.padding * options.scale}px"
      'font-family': options.dayOnMinute.fontFamily
      'font-weight': options.dayOnMinute.fontWeight
      'text-align': 'center'
      'line-height': '1.2'
      'white-space': 'nowrap'
      'text-shadow': options.dayOnMinute.textShadow
      'letter-spacing': "#{options.dayOnMinute.letterSpacing * options.scale}px"
      'box-sizing': 'border-box'
      'display': 'flex'
      'align-items': 'center'
      'justify-content': 'center'
    
    # Add stretch factor transform
    if options.dayOnMinute.stretchFactor != 1.0
      dayLabelStyles['transform'] = "scaleX(#{options.dayOnMinute.stretchFactor})"
      dayLabelStyles['transform-origin'] = 'center'
    
    # Add text stroke if enabled
    if options.dayOnMinute.textStroke > 0
      dayLabelStyles['-webkit-text-stroke'] = "#{options.dayOnMinute.textStroke * options.scale}px #{options.dayOnMinute.textStrokeColor}"
    
    div.find('.dayLabel').css(dayLabelStyles)
  else
    div.find('.dayLabel').css('display', 'none')
  
  # Update month label on hour hand
  if options.monthOnHour.enabled
    monthOffset = hrLength * options.monthOnHour.offsetPercent / 100
    labelWidth = 100
    labelHeight = options.monthOnHour.fontSize * options.scale + (options.monthOnHour.padding * options.scale * 2)
    monthLabelStyles =
      position: 'absolute'
      left: "#{monthOffset - labelWidth / 2}px" # center horizontally on the offset position
      top: "#{-labelHeight / 4}px" # slight adjustment above center
      width: "#{labelWidth}px"
      'font-size': "#{options.monthOnHour.fontSize * options.scale}px"
      'color': options.monthOnHour.color
      'background-color': options.monthOnHour.backgroundColor
      'border-radius': "#{options.monthOnHour.borderRadius * options.scale}px"
      'padding': "#{options.monthOnHour.padding * options.scale}px"
      'font-family': options.monthOnHour.fontFamily
      'font-weight': options.monthOnHour.fontWeight
      'text-align': 'center'
      'line-height': '1.2'
      'white-space': 'nowrap'
      'text-shadow': options.monthOnHour.textShadow
      'letter-spacing': "#{options.monthOnHour.letterSpacing * options.scale}px"
      'box-sizing': 'border-box'
      'display': 'flex'
      'align-items': 'center'
      'justify-content': 'center'
    
    # Add stretch factor transform
    if options.monthOnHour.stretchFactor != 1.0
      monthLabelStyles['transform'] = "scaleX(#{options.monthOnHour.stretchFactor})"
      monthLabelStyles['transform-origin'] = 'center'
    
    # Add text stroke if enabled
    if options.monthOnHour.textStroke > 0
      monthLabelStyles['-webkit-text-stroke'] = "#{options.monthOnHour.textStroke * options.scale}px #{options.monthOnHour.textStrokeColor}"
    
    div.find('.monthLabel').css(monthLabelStyles)
  else
    div.find('.monthLabel').css('display', 'none')
  
  # Recalculate marker lengths based on current size
  majorLength = options.size * options.majorMarker.lengthPercent / 100 * options.scale
  minorLength = options.size * options.minorMarker.lengthPercent / 100 * options.scale
  clockRadius = size / 2
  
  # Update markers (positioned relative to clock edge)
  div.find('.markers > .major').css
    top: "#{size / 2 - options.majorMarker.width * options.scale / 2}px"
    left: "#{size / 2 - (-clockRadius / options.scale + majorLength / options.scale + options.markerOffset) * options.scale}px"
    width: "#{majorLength}px"
    height: "#{options.majorMarker.width * options.scale}px"
    'background-color': options.majorMarker.color
    'transform-origin': "#{(-clockRadius / options.scale + majorLength / options.scale + options.markerOffset) * options.scale}px 50%"
  
  div.find('.markers > .minor').css
    top: "#{size / 2 - options.minorMarker.width * options.scale / 2}px"
    left: "#{size / 2 - (-clockRadius / options.scale + minorLength / options.scale + options.markerOffset) * options.scale}px"
    width: "#{minorLength}px"
    height: "#{options.minorMarker.width * options.scale}px"
    'background-color': options.minorMarker.color
    'transform-origin': "#{(-clockRadius / options.scale + minorLength / options.scale + options.markerOffset) * options.scale}px 50%"

update: (_, domEl) ->
  # compute the current time of day in milliseconds
  # note: this is not always the time elapsed since 00:00 of that day, as mentioned by @ruurd
  now = new Date()
  time = now.getHours()   * 1000 * 60 * 60 +
         now.getMinutes() * 1000 * 60 +
         now.getSeconds() * 1000 +
         now.getMilliseconds()

  div = $(domEl)
  pointers = div.find('.secPtr, .minPtr, .hrPtr')

  # Update date information
  dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
  monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  
  if options.dateCenter.enabled
    div.find('.dateText').text(now.getDate())
  
  if options.dayOnMinute.enabled
    dayText = dayNames[now.getDay()]
    if options.dayOnMinute.allCaps
      dayText = dayText.toUpperCase()
    div.find('.dayLabel').text(dayText)
  
  if options.monthOnHour.enabled
    monthText = monthNames[now.getMonth()]
    if options.monthOnHour.allCaps
      monthText = monthText.toUpperCase()
    div.find('.monthLabel').text(monthText)

  # Set the rotation of the pointers to what they should be at the current time
  # (without transition, to prevent the pointer from rotating backwards around the beginning of the day)
  # Disable transition
  pointers.removeClass('pointer')
  div.find('.secPtr').css('transform', 'rotate('+(-90+time/60000*360)+'deg)')
  div.find('.minPtr').css('transform', 'rotate('+(-90+time/3600000*360)+'deg)')
  div.find('.hrPtr').css('transform', 'rotate('+(-90+time/43200000*360)+'deg)')
  # Trigger a reflow, flushing the CSS changes (see http://stackoverflow.com/questions/11131875/what-is-the-cleanest-way-to-disable-css-transition-effects-temporarily)
  div[0].offsetHeight
  # Enable transition again
  pointers.addClass('pointer')

  div.find('.halfDisp').text(if time / 86400000 % 1 < 0.5 then 'am' else 'pm')

  # Trigger transition to the rotation of the pointers in 10s
  time += options.intervalLength * 1000
  div.find('.secPtr').css('transform', 'rotate('+(-90+time/60000*360)+'deg)')
  div.find('.minPtr').css('transform', 'rotate('+(-90+time/3600000*360)+'deg)')
  div.find('.hrPtr').css('transform', 'rotate('+(-90+time/43200000*360)+'deg)')

style: """
#{options.pos.x}
#{options.pos.y}
pointer-events: none

.clock
  width: #{options.sizePercent}vw
  height: #{options.sizePercent}vw
  position: relative
  pointer-events: none

.blur-area
  position: absolute
  border-radius: 50%
  width: #{options.size * options.scale}px
  height: #{options.size * options.scale}px
  top: 0px
  left: 0px
  pointer-events: none
  if #{options.backgroundBlur > 0}
    -webkit-backdrop-filter: blur(#{options.backgroundBlur}px)
    backdrop-filter: blur(#{options.backgroundBlur}px)

.disc
  position: absolute
  border-radius: 50%
  box-sizing: border-box
  width: #{options.size * options.disc.sizePercent / 100 * options.scale}px
  height: #{options.size * options.disc.sizePercent / 100 * options.scale}px
  top: #{(options.size * options.scale - options.size * options.disc.sizePercent / 100 * options.scale) / 2}px
  left: #{(options.size * options.scale - options.size * options.disc.sizePercent / 100 * options.scale) / 2}px
  background-color: #{options.disc.color}
  border: #{options.disc.borderWidth * options.scale}px solid #{options.disc.borderColor}
  box-shadow: 0px 0px #{10 * options.scale}px rgba(0,0,0,0.25)
  if #{options.disc.blur > 0}
    -webkit-backdrop-filter: blur(#{options.disc.blur}px)
    backdrop-filter: blur(#{options.disc.blur}px)

.pointer
  transition: transform #{options.intervalLength}s linear

.secPtr
  position: absolute
  top: #{options.size * options.scale / 2 - options.secPtr.width * options.scale / 2}px
  left: #{options.size * options.scale / 2 - options.secPtr.width / 2 * options.scale}px
  width: #{options.secPtr.length * options.scale}px
  height: #{options.secPtr.width * options.scale}px
  background-color: #{options.secPtr.color}
  border-left: 0px transparent solid
  border-top-left-radius: #{options.secPtr.width / 2 * options.scale}px
  border-bottom-left-radius: #{options.secPtr.width / 2 * options.scale}px
  box-shadow: 0px 0px #{15 / 2 * options.scale}px rgba(0,0,0,0.25)
  transform-origin: #{options.secPtr.width / 2 * options.scale}px 50%
  transform: rotate(-90deg)

.minPtr
  position: absolute
  top: #{options.size * options.scale / 2 - options.minPtr.width * options.scale / 2}px
  left: #{options.size * options.scale / 2 - options.minPtr.width / 2 * options.scale}px
  width: #{options.minPtr.length * options.scale}px
  height: #{options.minPtr.width * options.scale}px
  background-color: #{options.minPtr.color}
  border-left: 0px transparent solid
  border-top-left-radius: #{options.minPtr.width / 2 * options.scale}px
  border-bottom-left-radius: #{options.minPtr.width / 2 * options.scale}px
  box-shadow: 0px 0px #{12.5 * options.scale}px rgba(0,0,0,0.25)
  transform-origin: #{options.minPtr.width / 2 * options.scale}px 50%
  transform: rotate(-90deg)

.hrPtr
  position: absolute
  top: #{options.size * options.scale / 2 - options.hrPtr.width * options.scale / 2}px
  left: #{options.size * options.scale / 2 - options.hrPtr.width / 2 * options.scale}px
  width: #{options.hrPtr.length * options.scale}px
  height: #{options.hrPtr.width * options.scale}px
  background-color: #{options.hrPtr.color}
  border-left: 0px transparent solid
  border-top-left-radius: #{options.hrPtr.width / 2 * options.scale}px
  border-bottom-left-radius: #{options.hrPtr.width / 2 * options.scale}px
  box-shadow: 0px 0px #{10 * options.scale}px rgba(0,0,0,0.25)
  transform-origin: #{options.minPtr.width / 2 * options.scale}px 50%
  transform: rotate(-90deg)

.halfDisp
  display: none
  position: relative
  top: #{options.size * options.scale * 0.6}px
  left: #{options.size * options.scale * 0.6}px
  padding: 0px #{10 * options.scale}px
  font-family: Helvetica Neue
  font-size: #{options.fontSize * options.scale}px
  font-weight: 300
  color: rgba(0,0,0,0.6)
  box-shadow: 0px 0px #{10 * options.scale}px rgba(0,0,0,0.25) inset
  background: linear-gradient(rgba(0,0,0,0.1) 0%,rgba(0,0,0,0.04) 25%,rgba(0,0,0,0) 50%,rgba(0,0,0,0.04) 75%,rgba(0,0,0,0.1) 100%)

.markers > .major
  position: absolute
  top: #{options.size * options.scale / 2 - options.majorMarker.width * options.scale / 2}px
  left: #{options.size * options.scale / 2 - (-options.size / 2 + options.majorMarker.length + options.markerOffset) * options.scale}px
  width: #{options.majorMarker.length * options.scale}px
  height: #{options.majorMarker.width * options.scale}px
  background-color: #{options.majorMarker.color}
  transform-origin: #{(-options.size / 2 + options.majorMarker.length + options.markerOffset) * options.scale}px 50%

.markers > .minor
  position: absolute
  top: #{options.size * options.scale / 2 - options.minorMarker.width * options.scale / 2}px
  left: #{options.size * options.scale / 2 - (-options.size / 2 + options.minorMarker.length + options.markerOffset) * options.scale}px
  width: #{options.minorMarker.length * options.scale}px
  height: #{options.minorMarker.width * options.scale}px
  background-color: #{options.minorMarker.color}
  transform-origin: #{(-options.size / 2 + options.minorMarker.length + options.markerOffset) * options.scale}px 50%

.dateCenter
  position: absolute
  border-radius: 50%
  box-sizing: border-box
  z-index: 10
  pointer-events: none

.dateText
  pointer-events: none

.dayLabel, .monthLabel
  position: absolute
  box-sizing: border-box
  pointer-events: none
  transform-origin: center
"""
