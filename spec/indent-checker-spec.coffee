IndentChecker = require '../lib/indent-checker'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "IndentChecker", ->
  describe ".getLineType()", ->
    it "returns 'spaces' when the input starts with spaces", ->
      expect( IndentChecker.getLineType( "  foo" ) ).toBe( 'spaces' )

    it "returns 'tabs' when the input starts with tabs", ->
      expect( IndentChecker.getLineType( "\tfoo" ) ).toBe( 'tabs' )

    it "returns 'none' when the input starts with no indentation", ->
      expect( IndentChecker.getLineType( "foo" ) ).toBe( 'none' )

    it "returns 'none' when the input is empty", ->
      expect( IndentChecker.getLineType( "\n" ) ).toBe( 'none' )

    it "returns 'none' when the input starts a comment block", ->
      expect( IndentChecker.getLineType( "/**" ) ).toBe( 'none' )

    it "returns 'none' when the input ends a comment block", ->
      expect( IndentChecker.getLineType( " */" ) ).toBe( 'none' )

  describe ".getLinesByType()", ->
    it "returns an object with keys for each type found", ->
      input = "  foobar1\n  foobar2\n\tfoobar3\n  foobar4"
      types = IndentChecker.getLinesByType( input )
      expect( Object.keys( types ).length ).toBe( 2 )

    it "returns a list of lines for each type", ->
      input = "  foobar1\n  foobar2\n\n\tfoobar3\n  foobar4"
      types = IndentChecker.getLinesByType( input )
      expect( types[ 'spaces' ].length ).toBe( 3 )
      expect( types[ 'tabs' ].length ).toBe( 1 )

  describe ".getMostCommonIndentType()", ->
    it "returns 'spaces' when the input contains more space indentations than tabs", ->
      input = "  foobar1\n  foobar2\n\tfoobar3\n  foobar4\n"
      expect( IndentChecker.getMostCommonIndentType(input) ).toBe( 'spaces' )

    it "returns 'tabs' when the input contains more tabs indentations than spaces", ->
      input = "\tfoobar1\n\tfoobar2\n  foobar3\n\tfoobar4\n"
      expect( IndentChecker.getMostCommonIndentType(input) ).toBe( 'tabs' )

    it "returns 'none' when the input contains equal tab and space indentation", ->
      input = "\tfoobar1\n  foobar2\n\tfoobar3\n  foobar4\n"
      expect( IndentChecker.getMostCommonIndentType(input) ).toBe( 'none' )

  describe ".getLinesWithLessCommonType()", ->
    it "returns an array of line numbers with the less-common indentation type from the input", ->
      input = "  foobar1\n  foobar2\n\tfoobar3\n  foobar4\n"
      expect( IndentChecker.getLinesWithLessCommonType(input) ).toEqual([3])

    it "returns an empty array if the input is entirely one type", ->
      input = "  foobar1\n  foobar2\n  foobar3\n  foobar4\n"
      expect( IndentChecker.getLinesWithLessCommonType(input) ).toEqual([])

    it "returns an empty array if the input indentation types are equal", ->
      input = "  foobar1\n  foobar2\n\tfoobar3\n\tfoobar4\n"
      expect( IndentChecker.getLinesWithLessCommonType(input) ).toEqual([])

    it "ignores comment block indentations", ->
      input = "\tfoobar1\n/** foobar2\n * foobar3\n * foobar4\n */\n foobar6\n\tfoobar7"
      expect( IndentChecker.getLinesWithLessCommonType(input) ).toEqual([6])
