"use strict";

const { readFileSync, writeFileSync } = require("fs");

const raw = readFileSync("./dist/nomnoml.js", "utf-8");

let content = raw
  .replace(/\(factoryFn\)\s+\{([\s\S]+)factoryFn\(graphre\);/g, ($1, $2) =>
    $1.replace($2, "\t\nreturn ")
  )
  .replace(";(function (factoryFn)", "var nomnoml = (function (factoryFn)")
  // #fix warning at #L1526
  .replace("for(o=o||{},l=k.length;l--;o[k[l]]=v);", "for(o=o||{},l=k.length;l--;o[k[l]]=v){};")
  // #fix warning at #L1731
  .replace(/\}\s+return true;\n}};/, '\}\n}};');

// #fix for njs
const repairFragment = `var lastColumn = ''; if (lines && lines.length) { lastColumn = lines[lines.length - 1].length - lines[lines.length - 1].match(/\\r?\\n?/)[0].length; } else { lastColumn = this.yylloc.last_column + match[0].length; } this.yylloc = { first_line: this.yylloc.last_line, last_line: this.yylineno + 1, first_column: this.yylloc.last_column, last_column: lastColumn };`
const needRepairs = content.match(/this\.yylloc = \{\n[\s\S]+?\};/gm);
if(needRepairs.length){
  needRepairs.filter(text => text.includes('this.yylloc.last_column')).forEach(function(text){
    content = content.replace(text, repairFragment);
  });
}

writeFileSync("./dist/nomnoml.es5.js", content);
