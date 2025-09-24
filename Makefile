APP_NAME=database
PROTOC=protoc
PROTO_FILE=proto.proto
PROTO_PATH=.
OUT_DIR=./pkg/grpc
RELEASE_DIR=release

# Авто-версия из git (тег или commit hash)
VERSION := $(shell git describe --tags --always --dirty)

PROTOC_GEN_GO=$(shell command -v protoc-gen-go 2> /dev/null)
PROTOC_GEN_GO_GRPC=$(shell command -v protoc-gen-go-grpc 2> /dev/null)

.PHONY: proto run build clean check-tools install-tools deps \
        build-win release-win-amd64 release-win-arm64 \
        release-linux-amd64 release-linux-arm64 \
        release-mac-amd64 release-mac-arm64 \
        release-all release-local

deps:
	@if [ -z "$(PROTOC_GEN_GO)" ]; then \
		echo ">> Installing protoc-gen-go..."; \
		go install google.golang.org/protobuf/cmd/protoc-gen-go@latest; \
	else \
		echo ">> protoc-gen-go found: $(PROTOC_GEN_GO)"; \
	fi
	@if [ -z "$(PROTOC_GEN_GO_GRPC)" ]; then \
		echo ">> Installing protoc-gen-go-grpc..."; \
		go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest; \
	else \
		echo ">> protoc-gen-go-grpc found: $(PROTOC_GEN_GO_GRPC)"; \
	fi

check-tools: deps
ifndef PROTOC_GEN_GO
	$(error "protoc-gen-go not found. Run 'make install-tools'")
endif
ifndef PROTOC_GEN_GO_GRPC
	$(error "protoc-gen-go-grpc not found. Run 'make install-tools'")
endif

install-tools:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

proto: check-tools
	$(PROTOC) --proto_path=$(PROTO_PATH) \
		--go_out=$(OUT_DIR) --go-grpc_out=$(OUT_DIR) \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative \
		$(PROTO_FILE)
	go mod tidy

run: proto
	go run main.go

build: proto
	go build -o $(APP_NAME) main.go

# ---------- Windows ----------
release-win-amd64: proto
	GOOS=windows GOARCH=amd64 go build -o $(APP_NAME).exe main.go
	mkdir -p $(RELEASE_DIR)
	echo "# $(APP_NAME)"                 >  $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "**Version:** $(VERSION)"       >> $(RELEASE_DIR)/README.md
	echo "**Platform:** Windows amd64"   >> $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "## How to run"                 >> $(RELEASE_DIR)/README.md
	echo "1. Extract the archive."       >> $(RELEASE_DIR)/README.md
	echo "2. Run \`$(APP_NAME).exe\`"    >> $(RELEASE_DIR)/README.md
	zip -j $(RELEASE_DIR)/$(APP_NAME)-win64-$(VERSION).zip $(APP_NAME).exe $(RELEASE_DIR)/README.md
	rm -f $(APP_NAME).exe $(RELEASE_DIR)/README.md

release-win-arm64: proto
	GOOS=windows GOARCH=arm64 go build -o $(APP_NAME).exe main.go
	mkdir -p $(RELEASE_DIR)
	echo "# $(APP_NAME)"                 >  $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "**Version:** $(VERSION)"       >> $(RELEASE_DIR)/README.md
	echo "**Platform:** Windows arm64"   >> $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "## How to run"                 >> $(RELEASE_DIR)/README.md
	echo "1. Extract the archive."       >> $(RELEASE_DIR)/README.md
	echo "2. Run \`$(APP_NAME).exe\`"    >> $(RELEASE_DIR)/README.md
	zip -j $(RELEASE_DIR)/$(APP_NAME)-win-arm64-$(VERSION).zip $(APP_NAME).exe $(RELEASE_DIR)/README.md
	rm -f $(APP_NAME).exe $(RELEASE_DIR)/README.md

# ---------- Linux ----------
release-linux-amd64: proto
	GOOS=linux GOARCH=amd64 go build -o $(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "# $(APP_NAME)"                 >  $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "**Version:** $(VERSION)"       >> $(RELEASE_DIR)/README.md
	echo "**Platform:** Linux amd64"     >> $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "## How to run"                 >> $(RELEASE_DIR)/README.md
	echo "1. Extract the archive."       >> $(RELEASE_DIR)/README.md
	echo "2. Run \`./$(APP_NAME)\`"      >> $(RELEASE_DIR)/README.md
	tar -czf $(RELEASE_DIR)/$(APP_NAME)-linux64-$(VERSION).tar.gz $(APP_NAME) -C $(RELEASE_DIR) README.md
	rm -f $(APP_NAME) $(RELEASE_DIR)/README.md

release-linux-arm64: proto
	GOOS=linux GOARCH=arm64 go build -o $(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "# $(APP_NAME)"                 >  $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "**Version:** $(VERSION)"       >> $(RELEASE_DIR)/README.md
	echo "**Platform:** Linux arm64"     >> $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "## How to run"                 >> $(RELEASE_DIR)/README.md
	echo "1. Extract the archive."       >> $(RELEASE_DIR)/README.md
	echo "2. Run \`./$(APP_NAME)\`"      >> $(RELEASE_DIR)/README.md
	tar -czf $(RELEASE_DIR)/$(APP_NAME)-linux-arm64-$(VERSION).tar.gz $(APP_NAME) -C $(RELEASE_DIR) README.md
	rm -f $(APP_NAME) $(RELEASE_DIR)/README.md

# ---------- macOS ----------
release-mac-amd64: proto
	GOOS=darwin GOARCH=amd64 go build -o $(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "# $(APP_NAME)"                 >  $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "**Version:** $(VERSION)"       >> $(RELEASE_DIR)/README.md
	echo "**Platform:** macOS amd64"     >> $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "## How to run"                 >> $(RELEASE_DIR)/README.md
	echo "1. Extract the archive."       >> $(RELEASE_DIR)/README.md
	echo "2. Run \`./$(APP_NAME)\`"      >> $(RELEASE_DIR)/README.md
	tar -czf $(RELEASE_DIR)/$(APP_NAME)-mac64-$(VERSION).tar.gz $(APP_NAME) -C $(RELEASE_DIR) README.md
	rm -f $(APP_NAME) $(RELEASE_DIR)/README.md

release-mac-arm64: proto
	GOOS=darwin GOARCH=arm64 go build -o $(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "# $(APP_NAME)"                 >  $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "**Version:** $(VERSION)"       >> $(RELEASE_DIR)/README.md
	echo "**Platform:** macOS arm64"     >> $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "## How to run"                 >> $(RELEASE_DIR)/README.md
	echo "1. Extract the archive."       >> $(RELEASE_DIR)/README.md
	echo "2. Run \`./$(APP_NAME)\`"      >> $(RELEASE_DIR)/README.md
	tar -czf $(RELEASE_DIR)/$(APP_NAME)-mac-arm64-$(VERSION).tar.gz $(APP_NAME) -C $(RELEASE_DIR) README.md
	rm -f $(APP_NAME) $(RELEASE_DIR)/README.md

# ---------- Все релизы ----------
release-all: release-win-amd64 release-win-arm64 \
             release-linux-amd64 release-linux-arm64 \
             release-mac-amd64 release-mac-arm64

# ---------- Локальная сборка без архива ----------
release-local: proto
	go build -o $(RELEASE_DIR)/$(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "# $(APP_NAME)"                 >  $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "**Version:** $(VERSION)"       >> $(RELEASE_DIR)/README.md
	echo "**Platform:** Local build"     >> $(RELEASE_DIR)/README.md
	echo ""                              >> $(RELEASE_DIR)/README.md
	echo "## How to run"                 >> $(RELEASE_DIR)/README.md
	echo "1. Run \`./$(APP_NAME)\`"      >> $(RELEASE_DIR)/README.md

clean:
	rm -f $(APP_NAME)
	rm -f $(APP_NAME).exe
	rm -f $(OUT_DIR)/*.pb.go
	rm -rf $(RELEASE_DIR)