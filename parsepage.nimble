# Package

version       = "1.1.0"
author        = "Luciano Lorenzo"
description   = "Automatically extracts the data of sites"
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["parsepage"]

binDir = "build"

# Dependencies

requires "nim >= 1.6.4"

requires "https://github.com/thisago/fsafename"
requires "https://gitlab.com/lurlo/useragent"
requires "scraper"

requires "cligen"
requires "karax"
requires "nimquery"
requires "yaml"

task buildRelease, "Build release version":
  exec "nimble -d:release build"
