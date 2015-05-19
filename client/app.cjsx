React = require('react')
LinkedStateMixin = require('react/lib/LinkedStateMixin')

# react-bootstrap
Button = require 'react-bootstrap/lib/Button'
Col = require 'react-bootstrap/lib/Col'
Row = require 'react-bootstrap/lib/Row'
Grid = require 'react-bootstrap/lib/Grid'
ListGroup = require 'react-bootstrap/lib/ListGroup'
ListGroupItem = require 'react-bootstrap/lib/ListGroupItem'
Input = require 'react-bootstrap/lib/Input'

{StepStore, template} = require './steps/store'

stepActions = require './steps/actions'

DraggableMixin = {
  dragStart: (e) ->
    @dragged = e.currentTarget
    e.dataTransfer.effectAllowed = 'move'
    # Firefox requires calling dataTransfer.setData
    # for the drag to properly work
    e.dataTransfer.setData 'text/html', e.currentTarget
    return
  dragEnd: (e) ->
    @dragged.style.display = 'block'
    @dragged.parentNode.removeChild @placeholder
    # Update state
    data = @props.step.sub_steps
    # grab data-id for sorting
    from = Number(@dragged.dataset.id)
    to = Number(@over.dataset.id)
    if @nodePlacement == "after"
      to++
    if from < to
      to--
    data.splice(to, 0, data.splice(from, 1)[0])
    # update sub step order
    step = (_.extend({}, @props.step, {sub_steps:data}))
    stepActions.updateStep(step)
    return
  dragOver: (e) ->
    # TODO needs to detect the item being dragged over is part of it's items
    e.preventDefault()
    @dragged.style.display = 'none'
    if e.target.className == 'drop-placeholder list-group-item'
      return
    @over = e.target
    relY = e.clientY - (@over.offsetTop)
    height = @over.offsetHeight / 2
    parent = e.target.parentNode
    if relY > height
      @nodePlacement = 'after'
      parent.insertBefore @placeholder, e.target.nextElementSibling
    else if relY < height
      @nodePlacement = 'before'
      parent.insertBefore @placeholder, e.target
    return
  componentDidMount: ->
    # possibly create placeholder
    @placeholder = document.createElement("li")
    @placeholder.className = "drop-placeholder list-group-item"
    @placeholder.appendChild(document.createTextNode("drop here"))
}

StepDisplay = React.createClass

  mixins: [DraggableMixin]

  removeStep: ->
    stepActions.removeStep(@props.step)

  render: ->
    step = @props.step
    sub_num = 96
    subs = _.map step.sub_steps, (sub) =>
      sub_num++
      <ListGroupItem
          draggable="true"
          data-id={sub_num-97}
          onDragEnd={@dragEnd}
          onDragStart={@dragStart}
          key={sub.guid.toString()}>
        {String.fromCharCode(sub_num)}. {sub.action}
      </ListGroupItem>

    <div class="step">
      <h2>{@props.num}. {step.name}</h2>
      <Button onClick={@removeStep}>remove</Button>
      <ListGroup onDragOver={@dragOver}>
        {subs}
      </ListGroup>
    </div>


StepList = React.createClass
  getDefaultProps: ->
    steps: []

  getAllSteps: ->
    num = 0
    return _.map this.props.steps, (step) ->
      num++
      return <StepDisplay num={num} key={step.guid.toString()} step={step}/>

  render: ->
    all_steps = this.getAllSteps()

    <div className="step-section">
      {all_steps}
    </div>


StepCreatorForm = React.createClass
  mixins: [LinkedStateMixin]

  # propTypes:
  #   onUserInput: React.PropTypes.func.isRequired
  #   onClear: React.PropTypes.func.isRequired

  getEmptyStep: ->
    template()

  getInitialState: ->
    @getEmptyStep()

  clearForm: ->
    @setState(@getEmptyStep())

  handleSubmit: ->
    stepActions.addStep(@state)
    # clear diz shiz
    @clearForm()

  validationState: ->
    if @state.name.length < 10
      return 'warning'

        # value={@valueLink.value}
  render: ->
    <div>
      <Input
        type='text'
        label='step name'
        placeholder="name"
        bsStyle={@validationState()}
        valueLink={@linkState('name')}/>
      <Button bsStyle="primary" onClick={@handleSubmit}>Stuff n things</Button>
    </div>


StepsController = React.createClass
  mixins: [StepStore.mixin]

  storeDidChange: ->
    @setState(StepStore.getSteps())

  getInitialState: ->
    StepStore.getSteps()

  render: ->
    <Grid>
      <Row>
        <Col xs={6}>
          <StepList steps={@state.steps}/>
        </Col>
        <Col xs={6}>
          <StepCreatorForm/>
        </Col>
      </Row>
    </Grid>


app_div = document.getElementById('react_app')
React.render(<StepsController/>, app_div)
