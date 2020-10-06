BIN = ./node_modules/.bin
TESTS = *.test.js
MOCHA_OPTS = --recursive -b --timeout 15000 --reporter spec --exit

test: lint-fix
	@echo "Testing..."
	@NODE_ENV=test $(BIN)/_mocha $(MOCHA_OPTS) $(TESTS)
test-cov: lint
	@echo "Generating coverage html..."
	@NODE_ENV=test $(BIN)/nyc --reporter=lcov --reporter=text-summary $(BIN)/_mocha $(MOCHA_OPTS) $(TESTS)
test-coveralls: test-cov
	@echo "Submit coveralls job..."
	@cat ./coverage/lcov.info | $(BIN)/coveralls --verbose
.PHONY: lint lint-fix test test-cov test-coveralls
