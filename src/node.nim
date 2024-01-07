import std/[os, strutils]

type
  Node* = ref object
    chained*: bool
    data*: string

    prev*: Node
    next*: Node

proc get*(node: Node): string =
  if node.data[0] == '$':
    let potentialEnvName = node.data[1..node.data.len-1]
    if existsEnv(potentialEnvName):
      return getEnv(potentialEnvName)
  
  node.data
