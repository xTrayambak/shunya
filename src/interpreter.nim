import std/[os, options, strutils, posix], ./[parse, launcher]

proc cd*(node: Node) {.inline.} =
  let dir = node.absChild()

  if not dir.isSome:
    discard chdir(getHomeDir())
  else:
    let
      goto = dir.get().data

      fex = fileExists(goto)
      dex = dirExists(goto)

    if not dex and fex:
      echo "sh: " & goto & ": not a directory"
    elif not dex and not fex:
      echo "sh: " & goto & ": no such file or directory"
    else:
      discard chdir(dir.get().data)

proc help* {.inline.} =
  echo """
Shunya Shell

Builtins:
cd       Change the current directory
license  Print the license information
help     Print this information
exit     Exit the shell
  """

proc exit*(node: Node) {.noReturn.} =
  let exitCode = node
    .absChild()
  
  if exitCode.isSome:
    quit(exitCode.get().data.parseInt())
  else:
    quit(0)

proc envExport*(node: Node) =
  if node.next == nil:
    for env, val in envPairs():
      echo env & '=' & val
  else:
    let 
      envNode = node.next

      splitted = envNode.data.split('=')

      name = splitted[0]
      value = splitted[1]

    putEnv(name, value)

proc interpret*(node: Node) {.inline.} =
  case node.data:
    of "cd":
      cd(node)
    of "help":
      help()
    of "exit":
      exit(node)
    of "export":
      envExport(node)
    else:
      launch(node)
