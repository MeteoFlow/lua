.PHONY: all install test clean lint deps

LUA ?= lua
LUAROCKS ?= luarocks
BUSTED ?= busted

all: test

# Install dependencies
deps:
	$(LUAROCKS) install luasocket
	$(LUAROCKS) install luasec
	$(LUAROCKS) install lua-cjson
	$(LUAROCKS) install busted

# Install the package locally
install:
	$(LUAROCKS) make meteoflow-1.0.3-1.rockspec

# Run tests
test:
	$(BUSTED) spec/

# Run a specific test file
test-%:
	$(BUSTED) spec/$*_spec.lua

# Clean build artifacts
clean:
	rm -rf *.rock
	rm -rf lua_modules/

# Check syntax
lint:
	@for f in $$(find meteoflow -name "*.lua"); do \
		$(LUA) -e "loadfile('$$f')" && echo "OK: $$f" || echo "FAIL: $$f"; \
	done

# Run example (requires API_KEY env var)
example-%:
	$(LUA) examples/$*.lua

# Show version
version:
	@$(LUA) -e "print(require('meteoflow').VERSION)" 2>/dev/null || \
		$(LUA) -e "package.path = 'meteoflow/?.lua;?.lua;' .. package.path; print(require('meteoflow').VERSION)"
