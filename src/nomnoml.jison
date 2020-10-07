%{
  var join = (list, list2) => (list.push(...list2), list)
  var cons = (list, e) => (list.push(e), list)
  var last = (list) => (list[list.length-1])
  var Rel = (start, arrow, end)  => {
    var assoc = arrow.assoc
    var startLabel = arrow.startLabel
    var endLabel = arrow.endLabel
    return {assoc, start, end, startLabel, endLabel};
  }
  var Partition = (lines, nodes, rels)  => ({lines, nodes, rels})
  var Node = (type, name, parts)  => ({type, name, parts})
  function withRelTo(part, arrow, node) {
    part.rels.push({
      assoc: arrow.assoc,
      start: last(part.rels).end,
      end: node.name,
      startLabel: arrow.startLabel.trim(),
      endLabel: arrow.endLabel.trim()
    });
    part.nodes.push(node);
    return part;
  }
%}

%lex
%%

[ \n\t]*\|[ \n\t]*             return '|'
"\\\\"                         return 'LITERAL'
"\["                           return 'LITERAL'
"\]"                           return 'LITERAL'
"\|"                           return 'LITERAL'
"\;"                           return 'LITERAL'
"\;"                           return 'LITERAL'
"\<"                           return 'LITERAL'
"\>"                           return 'LITERAL'
"\-"                           return 'LITERAL'
"\+"                           return 'LITERAL'
\<[a-zA-Z]+\>                  return 'TYPE'
[<>+:_-]+                      return 'ARROW'
[^\[\]|;\n<>+:_-]              return 'TXT'
"["                            return '['
\n*\]                          return ']'
[ ]*[;\n]+[ ]*                 return 'SEP'
\\s*                           ;
<<EOF>>                        return 'EOF'
.                              return 'INVALID'
/lex

%start root

%%

root : partition EOF { return $partition };

text
 : LITERAL              -> $LITERAL.substr(1)
 | TXT                  -> $TXT
 | text LITERAL         -> $text + $LITERAL.substr(1)
 | text TXT             -> $text + $TXT
;

partition
 : chain                -> $1
 | node                 -> Partition([], [$1], [])
 | text                 -> Partition([$1], [], [])
 | partition SEP chain  -> join($partition.rels, $chain.rels) && join($partition.nodes, $chain.nodes) && $partition
 | partition SEP node   -> cons($partition.nodes, $node) && $partition
 | partition SEP text   -> cons($partition.lines, $text) && $partition
;

arrow
 : ARROW                -> { startLabel: '', assoc: $ARROW, endLabel: '' }
 | text ARROW           -> { startLabel: $text, assoc: $ARROW, endLabel: '' }
 | ARROW text           -> { startLabel: '', assoc: $ARROW, endLabel: $text }
 | text ARROW text      -> { startLabel: $1, assoc: $ARROW, endLabel: $3 }
;

chain
 : chain arrow node     -> withRelTo($chain, $arrow, $node)
 | node arrow node      -> Partition([], [$1,$3], [Rel($1.name,$arrow,$3.name)])
;

parts
 : partition            -> [$partition]
 | parts '|' partition  -> cons($parts, $partition)
;

node
 : '[' parts ']'        -> Node('<class>', $parts[0].lines[0], $parts)
 | '[' TYPE parts ']'   -> Node($TYPE, $parts[0].lines[0], $parts)
;
