Guid = require 'guid'
McFly = require 'mcfly'
_ = require 'lodash'

mcFly = new McFly();

_steps = [
  {
    guid: Guid.create()
    name: 'step name fo realz'
    actions: [{
        guid: Guid.create()
        action: 'move the screw'
      },{
        guid: Guid.create()
        action: 'take the screw out'
      }]
  }, {
    guid: Guid.create()
    name: 'another step name'
    actions: [{
        guid: Guid.create()
        action: 'move the screw'
      },{
        guid: Guid.create()
        action: 'take the screw out'
      }]
  } , {
    guid: Guid.create()
    name: 'so many steps'
    actions: [{
        guid: Guid.create()
        action: 'move the screw'
      },{
        guid: Guid.create()
        action: 'take the screw out'
      },{
        guid: Guid.create()
        action: 'put the screw back in'
      }]
  }
]


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
    steps: _steps
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
    }]
  action_template: ->
    guid: Guid.create()
    action: ''
  StepStore: StepStore
  mcFly: mcFly
}
