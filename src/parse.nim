import std/[options, strutils], node

const
  SHUNYA_TOK_BUFSIZE = 64
  SHUNYA_TOK_DELIM = ['\t', '\r', '\n', '\a', ' ']

#[
proc `=destroy`*(node: Node) =
  `=destroy`(node.data)

  if node.prev != nil:
    `=destroy`(node.prev)

  if node.next != nil:
    `=destroy`(node.next)

proc `=sink`*(dest: var Node, src: Node) =
  `=destroy`(dest)
  wasMoved dest

  dest.prev = src.prev
  dest.next = src.next
  dest.chained = src.chained

proc `=copy`*(dest: var Node, src: Node) =
  if dest.prev != src.prev and
    dest.next != src.next and
    dest.data != src.data:
    `=destroy`(dest)
    wasMoved dest

    dest.prev = duplicateResource(src.prev)
    dest.next = duplicateResource(src.next)
    dest.data = duplicateResource(src.data)
    dest.chained = duplicateResource(src.chained)
]#

iterator traverse*(node: Node): Node =
  ## Go down a Node's hierarchy, excluding itself
  assert node.prev != nil, "Cannot traverse further!"
  var curr: Node = node.prev

  while curr.prev != nil:
    yield curr

proc absParent*(node: Node): Option[Node] =
  var c = node

  while c.prev != nil:
    c = c.prev

  if c != node:
    return some(c)

proc absChild*(node: Node): Option[Node] =
  var c = node
  
  while c.next != nil:
    c = c.next

  if c != node:
    return some(c)

proc depth*(node: Node): int =
  var c = node

  while c.prev != nil:
    c = c.prev
    inc result

proc height*(node: Node): int =
  var c = node

  while c.next != nil:
    c = c.next
    inc result

iterator upwards*(node: Node): Node =
  ## Go up a Node's hierarchy, excluding itself
  assert node.next != nil, "Cannot traverse further!"
  var curr: Node = node.next

  while curr != nil:
    yield curr
    curr = curr.next

proc find*(node: Node, data: string): Option[Node] =
  for n in node.traverse():
    if n.data == data:
      return some(n)

proc parse*(line: string): Node =
  var 
    pos: int
    curr: char
    prev, node, first: Node
  
  node = Node()
  while pos < line.len:
    curr = line[pos]

    if curr == '"':
      if prev != nil:
        node.chained = not prev.chained
      else:
        node.chained = true
    else:
      if curr in SHUNYA_TOK_DELIM and not node.chained:
        prev = node
        node = Node()

        prev.next = node
        node.prev = prev
        inc pos
        continue

      node.data &= curr

    if first == nil:
      first = node
    
    inc pos

  first

export Node, get
