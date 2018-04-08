require "./rei_checker/*"
require "commander"

cli = Commander::Command.new do |cmd|
  cmd.use = "rei_checker"
  cmd.long = "A tool for checking the prices of various REI items"
  cmd.run do |options, arguments|
    qs = QueryURIs.new(arguments[0])
    rei = ReiInterface.new(qs, {"debug" => options.bool["debug"],
                                "sales" => options.bool["sales"]})
    rei.fetch
  end

  cmd.flags.add do |flag|
    flag.name = "debug"
    flag.long = "--debug"
    flag.short = "-d"
    flag.default = false
    flag.description = "Turns on debug output, i.e. it will barf the raw response from REI for you."
  end

  cmd.flags.add do |flag|
    flag.name = "sales"
    flag.long = "--sales"
    flag.short = "-s"
    flag.default = false
    flag.description = "Will only show items on sale in the output."
  end
end

Commander.run(cli, ARGV)
