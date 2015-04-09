metasqlqueryparser.js: metasqlqueryparser.peg
	node_modules/.bin/pegjs metasqlqueryparser.js

test: metasqlqueryparser.js
	node driver.js
