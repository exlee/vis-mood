# Please note, that [ ..., ..., function ] syntax is needed
# since AngularJS won't be able to inject variables when minified.
# You can also restrict angularjs injection keywords in
# configuration file and skip this.
MainController = ['$scope', ($scope) ->

  $scope.developers = []

  hire_counter = 1

  for i in [1..1]
    obj =
      name: "Developer #{hire_counter++}"
      mood: Math.random()-1.5

    $scope.developers.push(obj)

  $scope.msg = "Hello World"

  changeMood = (chance,min_mod,max_mod) ->
    for obj,key in $scope.developers
      if Math.random() <= chance
        change = Math.random()*(max_mod-min_mod)+min_mod
        obj.mood = obj.mood+change

        if obj.mood < -3
          fireSomeone(key)
          if obj.mood < -4
            obj.mood = -4
        if obj.mood > 2
          obj.mood = 2
          if Math.random() > 0.95
            hireSomeone()

  fireSomeone = (i) ->
    if i?
      who = i
    else
      len = $scope.developers.length
      if len == 1
        who = 0
      else
        who = Math.ceil(len*Math.random())
    d = $scope.developers
    $scope.developers =
      d.slice(0,who)
      .concat(d.slice(who+1,d.length))

  hireSomeone = ->
    obj =
      name: "Developer #{hire_counter++}"
      mood: -1

    $scope.developers.push(obj)


  $scope.freeFood    = -> changeMood(0.3, -0.1,0.3)
  $scope.workOnIE6   = -> changeMood(0.8, -2,0.2)
  $scope.workHarder = -> changeMood(0.5, -0.25,0)
  $scope.integration = -> changeMood(0.7, 0.3,1.0)
  $scope.beer = -> changeMood(0.3, 0.8,3)
  $scope.fire = (count) ->
    for i in [1..count]
      fireSomeone()
  $scope.makeExample = ->
    fireSomeone()
    changeMood(0.8, -2, 2)

  $scope.energydrink = -> changeMood(0.3, 0.3, 2)
  $scope.overhours = -> changeMood(0.4, -0.3, -0.1)
  $scope.fearmanagement = -> changeMood(0.5, -0.2, -0.1)
  $scope.hire = (count) ->
    for i in [1..count]
      hireSomeone()
  $scope.sort = ->
    $scope.developers = $scope.developers.sort (left,right) ->
      if left.mood > right.mood
        -1
      else
        1
  $scope.shake = ->
    d3.shuffle($scope.developers)


]
