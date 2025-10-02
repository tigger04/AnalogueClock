# Begin of styling options

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
    lengthPercent: 90 # length as % of clock diameter
    length: 230  # calculated dynamically
  minPtr:
    color: "rgb(120,166,214, 10%)" # css color string
    width: 10     # in px
    lengthPercent: 55 # length as % of clock diameter
    length: 184   # calculated dynamically
  hrPtr:
    color: "rgb(120,166,214, 10%)" # css color string
    width: 20     # in px
    lengthPercent: 35 # length as % of clock diameter
    length: 128   # calculated dynamically
  markerOffset: 4 # offset from the border of the clock in px
  majorMarker:
    color: "rgba(200, 200, 200, 30%)" # css color string for hour markers
    width: 7      # in px
    lengthPercent: 8 # length as % of clock diameter
    length: 60    # calculated dynamically
  minorMarker:
    color: "rgba(200, 200, 200, 25%)" # css color string for minute markers
    width: 1      # in px
    lengthPercent: 2   # length as % of clock diameter
    length: 40    # calculated dynamically
  intervalLength: 30  # interval between the transition triggers in seconds
  backgroundBlur: 0 # circular blur area amount in px, set to 0 to disable
  disc:
    sizePercent: 90 # disc size as % of overall clock size
    color: "rgba(0, 0, 0, 15%)" # disc background color
    borderWidth: 0 # border width in px  
    borderColor: "rgba(0,0,0,0%)" # disc background color
    blur: 3 # disc blur amount in px, set to 0 to disable

refreshFrequency: "30s" # change this as well when changing the intervalLength

# End of styling options

render: (_) -> """
<div class="clock">
  <div class="blur-area"></div>
  <div class="disc"></div>
  <div class="markers"></div>
  <div class="halfDisp">am</div>
  <div class="hrPtr"></div>
  <div class="minPtr"></div>
  <div class="secPtr"></div>
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
"""
