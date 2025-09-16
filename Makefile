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

.PHONY: proto run build clean check-tools install-tools \
        build-win release-win-amd64 release-win-arm64 \
        release-linux-amd64 release-linux-arm64 \
        release-mac-amd64 release-mac-arm64 \
        release-all

check-tools:
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
	echo "Application: $(APP_NAME)"       >  $(RELEASE_DIR)/README.txt
	echo "Version:     $(VERSION)"       >> $(RELEASE_DIR)/README.txt
	echo "Platform:    Windows amd64"    >> $(RELEASE_DIR)/README.txt
	echo ""                              >> $(RELEASE_DIR)/README.txt
	echo "Инструкция по запуску:"        >> $(RELEASE_DIR)/README.txt
	echo "1. Распакуйте архив."          >> $(RELEASE_DIR)/README.txt
	echo "2. Запустите $(APP_NAME).exe"  >> $(RELEASE_DIR)/README.txt
	zip -j $(RELEASE_DIR)/$(APP_NAME)-win64-$(VERSION).zip $(APP_NAME).exe $(RELEASE_DIR)/README.txt
	rm -f $(APP_NAME).exe $(RELEASE_DIR)/README.txt

release-win-arm64: proto
	GOOS=windows GOARCH=arm64 go build -o $(APP_NAME).exe main.go
	mkdir -p $(RELEASE_DIR)
	echo "Application: $(APP_NAME)"       >  $(RELEASE_DIR)/README.txt
	echo "Version:     $(VERSION)"       >> $(RELEASE_DIR)/README.txt
	echo "Platform:    Windows arm64"    >> $(RELEASE_DIR)/README.txt
	echo ""                              >> $(RELEASE_DIR)/README.txt
	echo "Инструкция по запуску:"        >> $(RELEASE_DIR)/README.txt
	echo "1. Распакуйте архив."          >> $(RELEASE_DIR)/README.txt
	echo "2. Запустите $(APP_NAME).exe"  >> $(RELEASE_DIR)/README.txt
	zip -j $(RELEASE_DIR)/$(APP_NAME)-win-arm64-$(VERSION).zip $(APP_NAME).exe $(RELEASE_DIR)/README.txt
	rm -f $(APP_NAME).exe $(RELEASE_DIR)/README.txt

# ---------- Linux ----------
release-linux-amd64: proto
	GOOS=linux GOARCH=amd64 go build -o $(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "Application: $(APP_NAME)"       >  $(RELEASE_DIR)/README.txt
	echo "Version:     $(VERSION)"       >> $(RELEASE_DIR)/README.txt
	echo "Platform:    Linux amd64"      >> $(RELEASE_DIR)/README.txt
	echo ""                              >> $(RELEASE_DIR)/README.txt
	echo "Инструкция по запуску:"        >> $(RELEASE_DIR)/README.txt
	echo "1. Распакуйте архив."          >> $(RELEASE_DIR)/README.txt
	echo "2. Выполните ./$(APP_NAME)"    >> $(RELEASE_DIR)/README.txt
	tar -czf $(RELEASE_DIR)/$(APP_NAME)-linux64-$(VERSION).tar.gz $(APP_NAME) -C $(RELEASE_DIR) README.txt
	rm -f $(APP_NAME) $(RELEASE_DIR)/README.txt

release-linux-arm64: proto
	GOOS=linux GOARCH=arm64 go build -o $(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "Application: $(APP_NAME)"       >  $(RELEASE_DIR)/README.txt
	echo "Version:     $(VERSION)"       >> $(RELEASE_DIR)/README.txt
	echo "Platform:    Linux arm64"      >> $(RELEASE_DIR)/README.txt
	echo ""                              >> $(RELEASE_DIR)/README.txt
	echo "Инструкция по запуску:"        >> $(RELEASE_DIR)/README.txt
	echo "1. Распакуйте архив."          >> $(RELEASE_DIR)/README.txt
	echo "2. Выполните ./$(APP_NAME)"    >> $(RELEASE_DIR)/README.txt
	tar -czf $(RELEASE_DIR)/$(APP_NAME)-linux-arm64-$(VERSION).tar.gz $(APP_NAME) -C $(RELEASE_DIR) README.txt
	rm -f $(APP_NAME) $(RELEASE_DIR)/README.txt

# ---------- macOS ----------
release-mac-amd64: proto
	GOOS=darwin GOARCH=amd64 go build -o $(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "Application: $(APP_NAME)"       >  $(RELEASE_DIR)/README.txt
	echo "Version:     $(VERSION)"       >> $(RELEASE_DIR)/README.txt
	echo "Platform:    macOS amd64"      >> $(RELEASE_DIR)/README.txt
	echo ""                              >> $(RELEASE_DIR)/README.txt
	echo "Инструкция по запуску:"        >> $(RELEASE_DIR)/README.txt
	echo "1. Распакуйте архив."          >> $(RELEASE_DIR)/README.txt
	echo "2. Выполните ./$(APP_NAME)"    >> $(RELEASE_DIR)/README.txt
	tar -czf $(RELEASE_DIR)/$(APP_NAME)-mac64-$(VERSION).tar.gz $(APP_NAME) -C $(RELEASE_DIR) README.txt
	rm -f $(APP_NAME) $(RELEASE_DIR)/README.txt

release-mac-arm64: proto
	GOOS=darwin GOARCH=arm64 go build -o $(APP_NAME) main.go
	mkdir -p $(RELEASE_DIR)
	echo "Application: $(APP_NAME)"       >  $(RELEASE_DIR)/README.txt
	echo "Version:     $(VERSION)"       >> $(RELEASE_DIR)/README.txt
	echo "Platform:    macOS arm64"      >> $(RELEASE_DIR)/README.txt
	echo ""                              >> $(RELEASE_DIR)/README.txt
	echo "Инструкция по запуску:"        >> $(RELEASE_DIR)/README.txt
	echo "1. Распакуйте архив."          >> $(RELEASE_DIR)/README.txt
	echo "2. Выполните ./$(APP_NAME)"    >> $(RELEASE_DIR)/README.txt
	tar -czf $(RELEASE_DIR)/$(APP_NAME)-mac-arm64-$(VERSION).tar.gz $(APP_NAME) -C $(RELEASE_DIR) README.txt
	rm -f $(APP_NAME) $(RELEASE_DIR)/README.txt

# ---------- Все релизы ----------
release-all: release-win-amd64 release-win-arm64 \
             release-linux-amd64 release-linux-arm64 \
             release-mac-amd64 release-mac-arm64

clean:
	rm -f $(APP_NAME)
	rm -f $(APP_NAME).exe
	rm -f $(OUT_DIR)/*.pb.go
	rm -rf $(RELEASE_DIR)