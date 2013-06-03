defmodule Bishop.CLI do

  @module_doc """
  Handle the command line parsing and the dispatch to the walk functions.
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  'argv' can be -h or --help, which returns :help.

  Otherwise it is a list of hexstrings.

  Return a list of hexstrings or ':help' if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean ],
                                     aliases:  [ h:    :help ])
  
    case parse do
      { [ help: true ], _ } -> :help
      { _, hexstrings }     -> hexstrings
      _                     -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage:  bishop <hexstring> ...
    """
    System.halt(0)
  end

  def process(hexstrings) do
    Enum.each hexstrings, fn (s) ->
      IO.puts s
      Bishop.walkhex s
    end
  end
end

