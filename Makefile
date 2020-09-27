.PHONY: test
.DEFAULT_GOAL := default
default: clean test build push clean

build:
	gem build mb-storage.gemspec

push:
	gem push --key github --host https://rubygems.pkg.github.com/mbriggs mb-storage-*.gem

clean:
	rm -f mb-storage-*.gem

test:
	ruby test/automated.rb
