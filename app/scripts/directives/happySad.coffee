angular_app.directive "happySad", ->
  restrict: 'E'
  replace: false
  scope:
    "developers": "=developers"
  link: (scope, element, attrs, controller) ->



    width = 520
    height = 620

    vis = d3.select(element[0])
      .append("svg")
      .attr("width",width)
      .attr("height",height)


    chart = vis.append("g")
      .classed("chart", true)

    chart.append("path")
      .attr("id", "chart_line")

    chart.append("line")
      .classed("yaxis", true)
      .attr("x1", 15)
      .attr("y1", 10)
      .attr("x2", 15)
      .attr("y2", 100)
      .attr("stroke", "black")

    chart.append("line")
      .classed("yaxis", true)
      .attr("x1", 15)
      .attr("y1", 100)
      .attr("x2", width-10)
      .attr("y2", 100)
      .attr("stroke", "black")

    chart.append("text")
      .text("Count")
      .attr("x", 10)
      .attr("y", 75)
      .attr("transform", "rotate(270,10,75)")
      .attr("fill", "black")


    mood_interpolator = d3.scale.linear()
      .domain([-4,2])
      .range([0,1])


    scope.$watch("developers",
      (o,n) ->
        return if o == n
        draw()
    , true)

    # Paths
    path_happy = "
    M0,100
    C0,100,100,100,100,100
    C95,180,5,180,0,100
    z
    "

    path_neutral ="
    M0,100
    C0,100,100,100,100,100
    C100,100,0,100,0,100
    z
    "

    path_sad = "
    M0,100
    C5,50,95,50,100,100
    C95,50,5,50,0,100
    "

    tintColor = (d) ->
      d3.rgb(mood_tint d.mood).darker(2)


    init_face = (face) ->
      face.append("circle")
        .classed("shape", true)
        .attr("fill", (d) -> mood_tint(d.mood))
        .attr("stroke", tintColor)
        .attr("stroke-width", 5)
        .attr("cx", 0)
        .attr("cy", 0)
        .attr("r", 50)

      face.append("circle")
        .classed("l_eye", true)
        .attr("stroke", tintColor)
        .attr("stroke-width", 2)
        .attr("fill", tintColor)
        .attr("cx", -20)
        .attr("cy", -20)
        .attr("r", 10)

      face.append("circle")
        .classed("r_eye", true)
        .attr("stroke-width", 2)
        .attr("fill", tintColor)
        .attr("stroke", tintColor)
        .attr("cx", 20)
        .attr("cy", -20)
        .attr("r", 10)

      face
        .append("path")
        .classed("mouth", true)
        .attr("stroke", tintColor)
        .attr("fill", tintColor)
        .attr("stroke-width", 3)
        .attr("transform",'translate(-25,-40), scale(0.5, 0.5)')
        .attr("d", (d,i) -> mood(d.mood))


    # Interpolator
    mood = (t) ->
      t = mood_interpolator(t)

      sad_neutral = d3.interpolate( path_sad, path_neutral)
      neutral_happy = d3.interpolate(path_neutral, path_happy)

      if t == 0.5
        path_neutral
      else if t < 0.5
        sad_neutral(t*2)
      else
        neutral_happy((t-0.5)*2)

    mood_tint = (t) ->
      t = mood_interpolator(t)

      sad_neutral = d3.interpolateRgb("#C73C2D", "#FFFFFF")
      neutral_happy = d3.interpolateRgb("#FFFFFF", "#83A443")

      if t == 0.5
        sad_neutral(1)
      else if t < 0.5
        sad_neutral(t*2)
      else
        neutral_happy((t-0.5)*2)

    drawChart = ->
      quantize = d3.scale.quantize()
        .range([0..10])
        .domain([-4,2])

      result = d3.nest()
      .key( (d) -> quantize(d.mood))
      .rollup( (d) -> d.length || 0 )
      .map(scope.developers)


      chart_scale_x = d3.scale.linear()
        .range([25,width-25])
        .domain([0,10])


      max_y = d3.max(d3.map(result).entries(),(d) -> d.value)
      chart_scale_y = d3.scale.linear()
        .range([90,30])
        .domain([0,max_y])

      line = d3.svg.line()
        .x( (d) -> chart_scale_x(d) )
        .y( (d) -> chart_scale_y(result[d] ? 0) )
        .interpolate "cardinal"
      

      dt = chart.selectAll("circle")
        .data([0..10])

      chart.select("#chart_line")
        .transition()
        .duration(500)
        .attr("d", line([0..10]))
        .attr("fill", "none")
        .attr("stroke", "#82A5B8")
        .attr("stroke-width", 2)
        .attr("shape-rendering", "geometricPrecision")

      circle_interpolator = d3.scale.linear()
        .range([-4,2])
        .domain([0,10])

      dt.enter().append("circle")
        .attr("cx", (d) -> chart_scale_x(d))
        .attr("cy", (d) -> chart_scale_y(result[d] ? 0 ))
        .attr("r", 5)
        .attr("stroke", (d) ->
          color = mood_tint(circle_interpolator(d))
          return d3.rgb(color).darker(2)
        )
        .attr("stroke-width", 2)
        .attr("fill", (d) ->
          color = mood_tint(circle_interpolator(d))
        )



      dt
        .transition()
        .duration(500)
        .attr("cx", (d) -> chart_scale_x(d))
        .attr("cy", (d) -> chart_scale_y(result[d] ? 0))
        .attr("stroke", (d) ->
          color = mood_tint(circle_interpolator(d))
          return d3.rgb(color).darker(2)
        )
        .attr("fill", (d) ->
          color = mood_tint(circle_interpolator(d))
        )


      dt.exit()
        .remove()


        
    draw = ->
      drawChart()
      people = vis.selectAll("g.people g.face")
        .data(scope.developers, (d,i) -> d.name)


      people.exit()
        .transition()
        .duration(500)
        .attr("opacity", 0)
        .transition()
        .remove()

      peoplePosition = (item) ->
        for i in ['shape', 'l_eye', 'r_eye', 'mouth']
          item.select("."+i).attr("stroke", tintColor)
        for i in ['l_eye', 'r_eye', 'mouth']
          item.select("."+i).attr("fill", tintColor)

        l = scope.developers.length
        perLine = Math.ceil( Math.sqrt(l))
        dim = 4/perLine
        if perLine < 4
          dim = 3/perLine

        item
        .attr("transform",
          (d,i) ->
            padMod = 1.2



            if Math.floor(i/perLine) % 2
              x = 100 + ((perLine-1) - i % perLine) * 100*padMod
            else
              x = 100 + (i % perLine) * 100*padMod
            y = 100 + Math.floor(i/perLine)*100*padMod

            "scale(#{dim},#{dim}),translate(#{x},#{y})"
        )


      people
        .transition()
        .duration(0)
        .attr("opacity", 1)
        .transition()
        .duration(500)
        .delay(500)
        .call(peoplePosition)

      people
        .enter()
        .append("g")
        .classed("people", true)
        .attr("transform", "translate(0,100)")
        .append("g")
        .classed("face", true)
        .call(init_face)
        .call(peoplePosition)
        .attr("opacity", 0)
        .transition()
        .duration(1500)
        .attr("opacity", 1)


      people
        .select(".mouth")
        .transition()
        .duration(1300)
        .attr("d", (d,i) -> mood(d.mood))
        .attr("fill", tintColor)
        .attr("stroke", tintColor)

      people
        .select(".shape")
        .transition()
        .duration(1300)
        .attr("fill", (d,i) -> mood_tint(d.mood))
        .attr("stroke", tintColor)

    draw()





