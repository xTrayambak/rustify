import std/[os, options, parseopt, sequtils]

type
  ArgumentKind* = enum
    akFlag # --foo:bar
    akTarget # bar
    akSwitch # --foo

  Argument* = ref object of RootObj
    case kind*: ArgumentKind
    of akFlag:
      key*: string
      value*: string
    of akTarget:
      target*: string
    of akSwitch:
      switch*: string
      abbreviation*: bool
        # Is abbreviation?
        # eg. --interactive: full form
        #     -I           : abbreviated form

proc getKey*(argument: Argument): string =
  if argument.kind == akFlag:
    return argument.key

  if argument.kind == akSwitch:
    return argument.switch

  ""

proc getValue*(argument: Argument): string =
  if argument.kind == akFlag:
    return argument.value

  if argument.kind == akTarget:
    return argument.target

  ""

proc isSwitchEnabled*(args: seq[Argument], long, short: string): bool =
  for arg in args:
    if arg.kind == akSwitch:
      if arg.switch == long or arg.switch == short:
        return true

  false

proc getFlag*(args: seq[Argument], name: string): Option[string] =
  for arg in args:
    if arg.kind == akFlag:
      if arg.key == name:
        return some(arg.value)

proc getFlags*(args: seq[Argument]): seq[Argument] =
  var flags: seq[Argument] = @[]

  for arg in filter(
    args,
    proc(arg: Argument): bool =
        arg.kind == akFlag
    ,
  ):
    flags.add(arg)

  flags

proc getTargets*(args: seq[Argument]): seq[string] =
  var targets: seq[string] = @[]

  for arg in args:
    if arg.kind == akTarget:
      targets.add(arg.target)

  targets

proc parseArguments*(): seq[Argument] =
  var
    args: seq[Argument] = @[]
    opt = initOptParser(commandLineParams())

  while true:
    opt.next()
    case opt.kind
    of cmdEnd:
      break
    of cmdShortOption:
      if opt.val.len < 1:
        args.add(Argument(kind: akSwitch, abbreviation: true, switch: opt.key))
      else:
        args.add(Argument(kind: akFlag, key: opt.key, value: opt.val))
    of cmdLongOption:
      if opt.val.len < 1:
        args.add(Argument(kind: akSwitch, abbreviation: true, switch: opt.key))
      else:
        args.add(Argument(kind: akFlag, key: opt.key, value: opt.val))
    of cmdArgument:
      args.add(Argument(kind: akTarget, target: opt.key))

  args
