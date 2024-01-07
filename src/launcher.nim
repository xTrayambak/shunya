import std/[posix, times], ./parse

proc launch*(node: Node): float32 {.discardable.} =
  var 
    start: float32
    pid = fork()
    args: seq[string]
    i: int
    status: cint

  start = cpuTime()

  var curr = node
    
  while curr != nil:
    var arg = curr.get()
    
    if curr.next != nil:
      arg &= ' '

    args.add arg
    curr = curr.next
  
  let cargs = allocCstringArray(args)

  if pid == 0:
    # Child process
    if execvp(node.data.cstring, cargs) == -1:
      echo "sh: " & node.data & ": command not found..."

    deallocCstringArray(cargs)

    quit QuitFailure
  elif pid < 0:
    # Error
    echo "sh: fork() syscall failed"
  else:
    # Parent process
    discard waitpid(Pid(pid), status, WUNTRACED)

    return cpuTime() - start
