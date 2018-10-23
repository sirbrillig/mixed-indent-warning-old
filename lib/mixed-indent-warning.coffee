IndentChecker = require '../lib/indent-checker'
{CompositeDisposable} = require 'atom'

module.exports = MixedIndentWarning =
  editor: null
  subscriptions: null
  commandSubscriptions: null

  config:
    alwaysScan:
      type: 'boolean'
      default: true
      title: 'Live Update'
      description: 'Scan files all the time.'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @commandSubscriptions = new CompositeDisposable
    @beginScans()
    @commandSubscriptions.add atom.commands.add 'atom-workspace', 'mixed-indent-warning:scan': => @scanActiveFile()

  deactivate: ->
    @subscriptions.dispose()
    @commandSubscriptions.dispose()

  beginScans: ->
    atom.config.observe 'mixed-indent-warning.alwaysScan', (alwaysScan) =>
      if alwaysScan
        @subscriptions.add atom.workspace.observeTextEditors (editor) =>
          @scanFile(editor)
          @subscriptions.add editor.onDidStopChanging =>
            @scanFile(editor)
      else
        @subscriptions.dispose()

  scanActiveFile: ->
    @scanFile(atom.workspace.getActiveTextEditor())

  clearMarkers: (editor) ->
    editor.findMarkers({MixedIndent: 'mixed-indent-incorrect'}).map (marker) ->
      marker.destroy()

  scanFile: (editor) ->
    @clearMarkers(editor)
    text = editor.getText()
    linesToDecorate = IndentChecker.getLinesWithLessCommonType(text)
    linesToDecorate.forEach (row) =>
      row = parseInt(row, 10) - 1
      marker = editor.markBufferRange([[row, 0], [row, Infinity]], invalidate: 'inside')
      marker.setProperties({MixedIndent: 'mixed-indent-incorrect'})
      editor.decorateMarker(marker, type: 'line-number', class: "mixed-indent-incorrect")
