RokuDevelop = require '../lib/roku-develop'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RokuDevelop", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('roku-develop')

  describe "when the roku-develop:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.roku-develop')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'roku-develop:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.roku-develop')).toExist()

        rokuDevelopElement = workspaceElement.querySelector('.roku-develop')
        expect(rokuDevelopElement).toExist()

        rokuDevelopPanel = atom.workspace.panelForItem(rokuDevelopElement)
        expect(rokuDevelopPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'roku-develop:toggle'
        expect(rokuDevelopPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.roku-develop')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'roku-develop:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        rokuDevelopElement = workspaceElement.querySelector('.roku-develop')
        expect(rokuDevelopElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'roku-develop:toggle'
        expect(rokuDevelopElement).not.toBeVisible()

  describe "when the roku-develop:switch-files event is triggered", ->
    it "opens a file with the same name", ->
      expect(true)
