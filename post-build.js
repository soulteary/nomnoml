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

writeFileSync("./dist/nomnoml.es5.js", content);
