Guid = require 'guid'
McFly = require 'mcfly'
_ = require 'lodash'
faker = require 'faker'

mcFly = new McFly();

getRandTo = (to=10, min=2) ->
  got = Math.floor(Math.random()*to)
  if min
    return _.max [min, got]
  return got

generate_random_steps = ->
  amount = getRandTo()
  steps = []

  for s in [0..amount]
    step_words = getRandTo(4)
    action_amount = getRandTo(6)
    actions = []
    for a in [0..action_amount]
      action_words = getRandTo(5)
      actions.push
        guid: Guid.create()
        action: faker.lorem.words(action_words).join(' ')
        image: faker.image.technics(600, 350)+"/"+getRandTo(10)+'/'
    steps.push
      guid: Guid.create()
      name: faker.lorem.words(step_words).join(' ')
      actions: actions

  return steps

# hold yer steps
_steps = generate_random_steps()
# _steps = []


# store accessors

addStep = (step) ->
  if not Guid.isGuid(step.guid)
    step.guid = Guid.create()
  _steps.push(step)
  return


removeStep = (step) ->
  if not Guid.isGuid(step.guid)
    throw Error('need step with guid when removing step!')
  _steps = _.remove _steps, (cur_step) ->
    return not cur_step.guid.equals(step.guid)
  return


updateStep = (step) ->
  # find step by it's guid and replace it with the new one
  _steps = _.map _steps, (cur_step) ->
    if cur_step.guid.equals(step.guid)
      return step
    else
      cur_step


StepStore = mcFly.createStore({
  getSteps: ->
    _steps
  }, (payload) ->
    switch payload.actionType
      when 'ADD_STEP'
        addStep(payload.step)
      when 'REMOVE_STEP'
        removeStep(payload.step)
      when 'UPDATE_STEP'
        updateStep(payload.step)
      else
        return true

    StepStore.emitChange()
    return true
)


module.exports = {
  template: ->
    guid: Guid.create()
    name: ''
    actions: [{
      guid: Guid.create()
      action: ''
      image: faker.image.technics(600, 350)+"/"+getRandTo(10)
    }]
  action_template: ->
    guid: Guid.create()
    action: ''
    image: faker.image.technics(600, 350)+"/"+getRandTo(10)
  StepStore: StepStore
  mcFly: mcFly
}
