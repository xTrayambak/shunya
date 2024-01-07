import std/[os, posix, rdstdin], ./[parse, interpreter]#, nimLUA

const NimblePkgVersion {.strdefine.} = "???"

proc loop: int =
  var
    line, args: string
    status = 1

  while status == 1:
    discard readLineFromStdin("sh$ ", line)
    
    if line.len > 0:
      let parsed = parse(line)
      interpret(parsed)

  0

proc interrupt {.inline noconv.} =
  discard

proc getConfigPath*: string =
  let home = getHomeDir()
  if fileExists(home / ".shunrc.lua"):
    return home / ".shunrc.lua"
  
  if fileExists(home / ".config" / "shunya" / "rc.lua"):
    return home / ".config" / "shunya" / "rc.lua"

  if fileExists(home / ".config" / "shunrc.lua"):
    return home / ".config" / "shunrc.lua"

  quit "No RC file found!"

proc main {.inline noReturn.} =
  if paramCount() > 0:
    case paramStr(1):
      of "--version":
        echo "shunya " & NimblePkgVersion
        quit(0)
      else:
        quit(0)

  #[var L = newNimLua()

  L.doFile(getConfigPath())]#

  # Initialize stuff
  setControlCHook(interrupt)

  discard setLocale(LC_ALL, "")
  putEnv("SHELL", getAppFilename())

  # Go into a loop
  quit(loop())

when isMainModule:
  main()
