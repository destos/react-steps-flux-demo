mcFly = require('./store').mcFly

module.exports = mcFly.createActions
    addStep: (step) ->
        actionType: 'ADD_STEP'
        step: step
    removeStep: (step) ->
        actionType: 'REMOVE_STEP'
        step: step
    updateStep: (step) ->
        actionType: 'UPDATE_STEP'
        step: step
