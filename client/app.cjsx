React = require('react')
# LinkedStateMixin = require('react/lib/LinkedStateMixin')

LinkedStateMixin = require('./react-catalyst/LinkedStateMixin').LinkedStateMixin
ClickOutsideMixin = require('react-onclickoutside')
ContentEditable = require('react-wysiwyg')

# react-bootstrap
Button = require 'react-bootstrap/lib/Button'
ButtonGroup = require 'react-bootstrap/lib/ButtonGroup'
Col = require 'react-bootstrap/lib/Col'
Row = require 'react-bootstrap/lib/Row'
Grid = require 'react-bootstrap/lib/Grid'
ListGroup = require 'react-bootstrap/lib/ListGroup'
ListGroupItem = require 'react-bootstrap/lib/ListGroupItem'
Input = require 'react-bootstrap/lib/Input'
Glyphicon = require 'react-bootstrap/lib/Glyphicon'
Thumbnail = require 'react-bootstrap/lib/Thumbnail'

{StepStore, template, action_template} = require './steps/store'

stepActions = require './steps/actions'

DraggableMixin = {
  isPartOfDragGroup: (e) ->
    return _.includes e.target.parentNode.children, @dragged

  dragStart: (e) ->
    # prevent dragging if editing an action
    if @state.editingAction
      return
    @dragged = e.currentTarget
    e.dataTransfer.effectAllowed = 'move'
    # Firefox requires calling dataTransfer.setData
    # for the drag to properly work
    e.dataTransfer.setData 'text/html', e.currentTarget
    return

  dragEnd: (e) ->
    if not @isPartOfDragGroup(e)
      return
    @dragged.style.display = 'block'
    @dragged.parentNode.removeChild @placeholder
    # Update state
    data = @props.step.actions
    # grab data-id for sorting
    from = Number(@dragged.dataset.id)
    to = Number(@over.dataset.id)
    if @nodePlacement == "after"
      to++
    if from < to
      to--
    data.splice(to, 0, data.splice(from, 1)[0])
    # update action order
    step = (_.extend({}, @props.step, {actions:data}))
    stepActions.updateStep(step)
    return

  dragOver: (e) ->
    e.preventDefault()
    # if we aren't a sibling of what's being dragged over exit
    if not @dragged or not @isPartOfDragGroup(e)
      return
    if e.target.className == 'drop-placeholder list-group-item'
      return
    @dragged.style.display = 'none'
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


EdiableActionItem = React.createClass
  mixins: [ClickOutsideMixin]

  getInitialState: ->
    editing: false

  onChange: (text) ->
    @setState action: text

  handleClickOutside: ->
    @setState(editing: false)

  startEditing: ->
    @setState(editing: true)

  render: ->
    action = @props.action
    actionNum = @props.num

    editing = @state.editing
    grabIcon = null
    # turn on grab icon if we're not editing the action
    if not editing
      grabIcon = <Glyphicon className="pull-right" style={cursor: 'move'} glyph="menu-hamburger"></Glyphicon>
    <ListGroupItem
        draggable="true"
        data-id={actionNum}
        className="clearfix"
        style={cursor: 'pointer'}
        onDoubleClick={@startEditing}
        {...@props}>
      <div className="pull-left">
        {String.fromCharCode(actionNum + 97)}.&nbsp;
      </div>
      {grabIcon}
      <div
        style={marginRight: '30px'}>
        {action.action}
      </div>
    </ListGroupItem>


StepDisplay = React.createClass

  mixins: [DraggableMixin, ClickOutsideMixin]

  removeStep: ->
    stepActions.removeStep(@props.step)

  getInitialState: ->
    highlightedAction: _.first(@props.step.actions)
    editingAction: undefined

  setHighlighted: (action) ->
    @setState(highlightedAction: action)

  handleClickOutside: (e) ->
    # click outside and then save the action being edited
    if @state.editingAction
      console.log 'clicking outside, cancel edit', arguments, @
      @setState(editingAction: undefined)
      # update with step and it's current text changes
      stepActions.updateStep(@props.step)

  render: ->
    step = @props.step
    actions = _.map step.actions, (action, actionNum) =>
      <EdiableActionItem
        key={action.guid.toString()}
        num={actionNum}
        action={action}
        editingAction={@state.editingAction}
        onDragEnd={@dragEnd}
        onDragStart={@dragStart}
        onMouseOver={@setHighlighted.bind(@, action)}>
      </EdiableActionItem>

    images = _.map step.actions, (action, action_num) =>
      <Col xs={4} key={action.guid.toString()}>
        <Thumbnail
          src={action.image}
          style={cursor: 'pointer'}
          onClick={@setHighlighted.bind(@, action)}></Thumbnail>
      </Col>

    if @state.highlightedAction
      image = <Thumbnail src={@state.highlightedAction.image}>
        <span>
          {@state.highlightedAction.action}
        </span>
      </Thumbnail>
    else
      image = undefined

    <div className="step">
      <div className="clearfix">
        <h2 className="pull-left">{@props.num}. {step.name}</h2>
        <Button className="pull-right" style={marginTop: '22px'} bsStyle="danger" onClick={@removeStep}>remove</Button>
      </div>
      <Row>
        <Col xs={12} md={7}>
          <h3>images</h3>
          {image}
          <Row>
            {images}
          </Row>
        </Col>
        <Col xs={12} md={5}>
          <h3>actions</h3>
          <ListGroup onDragOver={@dragOver}>
            {actions}
          </ListGroup>
        </Col>
      </Row>
    </div>


StepList = React.createClass
  getDefaultProps: ->
    steps: []

  getAllSteps: ->
    return _.map @props.steps, (step, num) ->
      return <StepDisplay num={num+1} key={step.guid.toString()} step={step}/>

  render: ->
    all_steps = this.getAllSteps()

    <div className="step-section">
      {all_steps}
    </div>


StepCreatorForm = React.createClass
  mixins: [LinkedStateMixin]

  getDefaultProps: ->
    lengthRequirement: 5

  getEmptyStep: ->
    template()

  getInitialState: ->
    @getEmptyStep()

  clearForm: ->
    @setState(@getEmptyStep())

  handleSubmit: ->
    # clean our empty actions
    @state.actions = _.filter @state.actions, (action) ->
      # has an action
      if !!action.action
        return action
      return false
    stepActions.addStep(@state)
    # clear diz shiz
    @clearForm()

  validationName: ->
    if @state.name.length < @props.lengthRequirement
      return 'error'
    else
      return 'success'

  validationAction: (action_i) ->
    if @state.actions[action_i].action.length < @props.lengthRequirement
      return 'error'
    else
      return 'success'

  moreSubSteps: ->
    @state.actions.push(action_template())
    @setState @state

  render: ->
    action_inputs = _.map @state.actions, (action, i) =>
      <Input
        type="text"
        label={"action (" + String.fromCharCode(i+97) + ")"}
        bsStyle={@validationAction(i)}
        ref={"action.#{i}"}
        valueLink={@linkState("actions.#{i}.action")}>
      </Input>

    <div>
      <Input
        type='text'
        label='step name'
        ref='name'
        help="the name used to referenced this step."
        bsStyle={@validationName()}
        valueLink={@linkState('name')}>
        </Input>
      <h3>step actions</h3>
      {action_inputs}
      <ButtonGroup>
        <Button bsStyle="default" onClick={@moreSubSteps}>Add an action</Button>
        <Button bsStyle="primary" onClick={@handleSubmit}>Submit</Button>
      </ButtonGroup>
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
        <Col xs={12} md={10} mdOffset={1}>
          <h2>List of steps</h2>
          <StepList steps={@state.steps}/>
          <h2>Add a new step</h2>
          <StepCreatorForm/>
        </Col>
      </Row>
    </Grid>


app_div = document.getElementById('react_app')
React.render(<StepsController/>, app_div)
