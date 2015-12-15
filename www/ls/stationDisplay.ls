container = d3.select ig.containers.base .append \div
  ..attr \id \detail

top = container.append \div

header = top.append \h2
particleNotes = {}
  ..no2 = top.append \p
    ..html "Zobrazeny hodinové průměry koncentrace NO<sub>2</sub>. Zobrazit koncentrace "
    ..append \a
      ..attr \href \#
      ..html "polétavého prachu PM10"
      ..on \click ->
        particleNotes[currentParticle].classed \active no
        ig.displayStation null, "pm10"
        particleNotes[currentParticle].classed \active yes
    ..append \span .html "."
  ..pm10 = top.append \p
    ..html "Zobrazeny hodinové průměry koncentrace PM10. Zobrazit koncentrace "
    ..append \a
      ..attr \href \#
      ..html "NO<sub>2</sub>"
      ..on \click ->
        particleNotes[currentParticle].classed \active no
        ig.displayStation null, "no2"
        particleNotes[currentParticle].classed \active yes
    ..append \span .html "."
    # ..on \click


width = 784
height = 200
canvas = container.append \canvas
  ..attr \width "#{width}px"
  ..attr \height "#{height}px"
ctx = canvas.node!getContext \2d
ctx.translate 0.5 0.5
yScale = {}
yScale.no2 = d3.scale.linear!
  ..range [0 height]
  ..domain [166 0]
yScale.pm10 = d3.scale.linear!
  ..range [0 height]
  ..domain [200 0]
data = {}
for particle in <[pm10 no2]>
  data[particle] = d3.tsv.parse ig.data[particle], (row) ->
    for field, value of row
      row[field] = parseFloat value
    row

colors = ['#d73027','#fc8d59','#fee08b','#d9ef8b','#91cf60','#1a9850'].reverse!
colorScale = {}
  ..no2 = d3.scale.threshold!
    ..domain [25 50 100 200 400]
    ..range colors
  ..pm10 = d3.scale.threshold!
    ..domain [15 30 50 70 150]
    ..range colors

currentParticle = "no2"
particleNotes[currentParticle].classed \active yes
currentStation = null
ig.displayStation = (station, particle) ->
  currentParticle := particle if particle
  currentStation  := station if station
  header.html currentStation.name
  ctx.clearRect 0, 0, width, height
  for row, index in data.pm10
    value = row[currentStation.name]
    ctx
      ..beginPath!
      ..strokeStyle = colorScale[currentParticle] value
      ..moveTo index, height
      ..lineTo index, yScale[currentParticle] value
      ..stroke!