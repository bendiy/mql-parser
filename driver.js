#!/usr/bin/env node

var parser = require('metasqlqueryparser')
  , util   = require('util')
  , fs     = require('fs')
  , args   = process.argv.slice(2)
  , ifile, istream
  , ofile, ostream
  , pfile, pstream
  , params
  , mql
  , sql
  ;

function printVersion() {
  util.puts("mqlparser " + mqlparser.VERSION);
}

function usage() {
  util.puts("Usage: mqlparser [ -o outputfile ] [ -p paramsfile ] input_file");
}

function exit(code, showUsage) {
  if (isString(code)) {
    utils.puts(code);
    if (showUsage) usage();
    process.exit(1);
  } else if (isNumber(code)) {
    if (showUsage) usage();
    process.exit(code);
  } else {
    if (showUsage) usage();
    process.exit(0);
  }
}

while (args.length > 0) {
  switch (args[0]) {
    case '-o':
      if (args.length < 2) {
        exit("Missing outputfile", true);
      }
      ofile = args[1];
      args.shift();
      break;
    case '-p':
      if (args.length < 2) {
        exit("Missing paramsfile", true);
      }
      pfile = args[1];
      args.shift();
      break;
    default:
      ifile = args[0];
      if (args.length > 1) {
        utils.puts("ignoring extra args");
        args.shift(args.length);
      }
      break;
  }
  args.shift();
}

istream = ifile ? fs.createReadStream(ifile)  : process.stdin;
ostream = ofile ? fs.createWriteStream(ofile) : process.stdout;
pstream = pfile ? fs.createReadStream(pfile);

istream.on('error', function() { exit('Cannot read from "' + ifile + '"'); });
ostream.on('error', function() { exit('Cannot write to "'  + ofile + '"'); });
pstream.on('error', function() { exit('Cannot read from "' + pfile + '"'); });
