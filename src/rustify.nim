import std/[strutils, options, random], argparse

const
  STARTING_POINTS = [
    "Did someone mention Rust? RUST!?!?!?!?",
    "May I introduce you to the Rust programming language?",
    "I see that you wrote your project in the C (🤮) programming language, have you thought of rewriting (⚡) it in RUST (🚀)?!?",
    "Do you want to learn the best language for the new technological era!?!?!?1",
    "OMG imagine using that disgusting language over RUST", "",
  ]
  TALKING_POINTS = [
    "memory safety", "fast build times", "did i forget to mention cargo?",
    "perfect syntax", "no memory corruption", "the huge ecosystem",
    "better than the C++ programming language", "blazingly fast", "friendly community",
    "better than the C programming language", "helpful error messages",
    "useful documentation", "better than the Nim programming language",
    "better than the Go programming language",
    "better than the Zig programming language", "powerful borrow checking",
    "no memory bugs", "no runtime overhead at all", "not-at-all-rushed macro system",
    "no garbage collector to slow your code down", "amazing trait system",
    "generics which have never been implemented before", "cute turbofish operators",
  ]
  ENDING_POINTS = [
    "I hope this motivates you to learn the best programming language ever made!1",
    "All hail our Lord and Saviour, Graydon Hoare@!1",
    "Please don't get a restraining order on me on the grounds of mental illness!!1",
    "The Rust book is your holy book from today onwards!",
    "Accept Ferris as your supreme leader!",
    "Shame on you for still having them when Rust exists. Tired of being bad? Time to learn Rust.",
    "There’s no other option. They just do. If you like dynamic typing, you need some help. Seriously. By using a dynamically typed and interpreted language (which means it's slow!), you are committing genocide and harming the environment more than gas cars.",
    "Bow to the superiority of the Turbofish!"
  ]
  CRAB = "🦀"
  ZAP = "⚡"
  ROCKET = "🚀"
  TURBOFISH = "::<>"

proc punctuationSpam(): string {.inline, raises: [].} =
  for _ in 0 .. rand(3 .. 7):
    result &= sample ['!', '?', '1', '/']
  result &= "! "

proc randEmoji(): string {.inline, raises: [].} =
  sample [CRAB, ZAP, ROCKET, TURBOFISH]

proc emojiSpam(): string {.inline, raises: [].} =
  for _ in 0 .. rand(1 .. 3):
    result &= randEmoji()

proc disgustEmoji(): string {.inline, gcsafe, raises: [].} =
  sample ["🤮", "🤮", "🤒"]

proc extraBloat(w: string): string {.raises: [], gcsafe.} =
  case w.toLowerAscii()
  of "rust", "ecosystem", "safety", "borrow", "ferris":
    return " (" & randEmoji() & ")"
  of "c++", "c", "nim", "zig", "go", "overhead", "collector":
    return " (" & disgustEmoji() & ")"
  of "fast":
    return " (" & ZAP & ")"
  of "safe", "community":
    return " (" & CRAB & ")"
  of "turbofish":
    return " (" & TURBOFISH & ")"
  else:
    discard

proc build(
    numTalkingPoints: uint, allowRedundantPoints: bool = true
): string {.inline, sideEffect, raises: [].} =
  randomize()
  var
    ramble = (sample STARTING_POINTS) & ' ' & emojiSpam() & ' '
    usedPoints: seq[string]

  for _ in 0 .. numTalkingPoints:
    var p = sample TALKING_POINTS

    if p in usedPoints:
      if allowRedundantPoints:
        p = "Oh, and have I mentioned " & p
      else:
        while p in usedPoints:
          p = sample TALKING_POINTS
    else:
      usedPoints.add(p)

    if rand(0 .. 3) != 0:
      p = toUpperAscii(p)

    ramble &= p
    if rand(0 .. 4) == 2:
      ramble &= emojiSpam()

    ramble &= punctuationSpam()

  ramble &= emojiSpam() & ' ' & (sample ENDING_POINTS) & ' '

  var final: string

  for w, isSep in tokenize(ramble):
    final &= w

    if not isSep:
      final &= extraBloat(w)

  final

proc help {.inline, noReturn, raises: [].} =
  echo """
rustify [options]
Generate some delectable Rust copypasta, delivered straight from the oven.

Options
  --talking-points=<unsigned integer>         The number of talking points to use
  --redundant-points=<on/off/true/false/0/1>  Whether to allow the usage of redundant points (they'll become with "have I mentioned <topic>?")

Examples
  rustify --talking-points=32 | wl-copy # Copy it and commit pasta
  rustify --talking-points=16 >> shakespeare.txt"""
  quit 0

proc main() {.inline.} =
  let 
    args = parseArguments()
    tPoints = args.getFlag("talking-points")
    
    talkingPoints = if tPoints.isSome:
      tPoints.unsafeGet().parseUint()
    else:
      0'u

    rPoints = args.getFlag("redundant-points")

    allowRedundantPoints = if rPoints.isSome:
      rPoints.unsafeGet().parseBool()
    else:
      true

  if args.isSwitchEnabled("help", "h"):
    help()
  
  stdout.write build(
    talkingPoints,
    allowRedundantPoints
  ) & '\n'

when isMainModule:
  main()
  quit 0
