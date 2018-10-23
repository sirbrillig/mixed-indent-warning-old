MixedIndentWarning = require '../lib/mixed-indent-warning'
path = require 'path'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MixedIndentWarning", ->
  [workspaceElement, activationPromise] = []
  fixturePath = path.join(__dirname, 'fixtures')

  beforeEach ->
    activationPromise = atom.packages.activatePackage('mixed-indent-warning')

  afterEach ->
    atom.config.unset('mixed-indent-warning.alwaysScan')

  describe "when live updating is enabled", ->
    beforeEach ->
      atom.config.set('mixed-indent-warning.alwaysScan', 'true')

    describe "when the file is opened", ->
      it "shows a decoration if there are two types of indentation in the file", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'more-spaces.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            expect( editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).length ).toEqual 2

      it "does not show a decoration if all indentation in the file is the same", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'equal-tabs-spaces.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            expect( editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).length ).toEqual 0

      it "shows a decoration next to lines with the less common indentation", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'more-spaces.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            rows = editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).reduce (rows, marker) ->
              rows = rows.concat( marker.getBufferRange().getRows() )
            , []
            expect(rows).toEqual([4, 5])

    describe "when the open file is changed to make indentation types equal", ->
      it "does not show a decoration", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'more-tabs.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            newText = "  foobar1\n  foobar2\n\tfoobar3\n\tfoobar4\n"
            editor.setText(newText)
            advanceClock(500)
            expect( editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).length ).toEqual 0

    describe "when the open file is changed to make indentation types unequal", ->
      it "shows a decoration for each line with less common indentation", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'equal-tabs-spaces.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            newText = "\tfoobar1\n\tfoobar2\n  foobar3\n\tfoobar4\n"
            editor.setText(newText)
            advanceClock(500)
            expect( editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).length ).toEqual 1

  describe "when live updating is disabled", ->
    beforeEach ->
      atom.config.set('mixed-indent-warning.alwaysScan', 'false')

    describe "when the mixed-indent-warning:scan command is not triggered", ->
      it "shows no decorations if there are two types of indentation in the file", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'more-spaces.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            expect( editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).length ).toEqual 0

    describe "when the mixed-indent-warning:scan command is triggered", ->
      it "shows a decoration if there are two types of indentation in the file", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'more-spaces.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            atom.commands.dispatch atom.views.getView(atom.workspace), 'mixed-indent-warning:scan'
            expect( editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).length ).toEqual 2

      it "does not show a decoration if all indentation in the file is the same", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'equal-tabs-spaces.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            atom.commands.dispatch atom.views.getView(atom.workspace), 'mixed-indent-warning:scan'
            expect( editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).length ).toEqual 0

      it "shows a decoration next to lines with the less common indentation", ->
        waitsForPromise ->
          atom.workspace.open(path.join(fixturePath, 'more-spaces.txt')).then (editor) ->
            expect(editor.getText().length).toBeGreaterThan 1
            atom.commands.dispatch atom.views.getView(atom.workspace), 'mixed-indent-warning:scan'
            rows = editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).reduce (rows, marker) ->
              rows = rows.concat( marker.getBufferRange().getRows() )
            , []
            expect(rows).toEqual([4, 5])
