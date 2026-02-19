.PHONY: build test clean install run help

BINARY_NAME=envswitch
GO=/usr/local/go/bin/go
SRC=main.go
DIST=dist

build:
	mkdir -p $(DIST)
	$(GO) build -o $(DIST)/$(BINARY_NAME) $(SRC)

test:
	$(GO) test -v ./...

clean:
	rm -rf $(DIST) .env .env.backup

install: build
	mkdir -p ~/.local/bin
	cp $(DIST)/$(BINARY_NAME) ~/.local/bin/
	@echo "Add ~/.local/bin to your PATH"

run: build
	./$(DIST)/$(BINARY_NAME)

help:
	@echo "Available targets:"
	@echo "  build    - Build the binary"
	@echo "  test     - Run tests"
	@echo "  clean    - Remove built files"
	@echo "  install  - Install to ~/.local/bin"
	@echo "  run      - Build and run"
	@echo "  help     - Show this help"
