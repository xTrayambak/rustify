# Package

version       = "0.1.0"
author        = "xTrayambak"
description   = ":crab: :zap: :rocket:"
license       = "GPL-2.0-only"
srcDir        = "src"
bin           = @["rustify"]


# Dependencies

requires "nim >= 2.0.2"

taskRequires "fmt", "nph >= 0.5.0"

task fmt, "Format scheisse":
  exec "nph src/"

after build:
  exec "strip ./rustify"
