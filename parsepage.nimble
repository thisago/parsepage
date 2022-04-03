# Package

version       = "0.1.0"
author        = "Luciano Lorenzo"
description   = "Automatically extracts the data of sites"
license       = "GPL-3.0-only"
srcDir        = "src"
bin           = @["parsepage"]


# Dependencies

requires "nim >= 1.7.1"
requires "cligen"
requires "useragent"
requires "scraper"
requires "yaml"

task buildRelease, "Build release version":
  exec "nimble -d:release build"
