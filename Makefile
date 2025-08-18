APP_NAME=database
PROTOC=protoc
PROTO_FILE=proto.proto
PROTO_PATH=.
OUT_DIR=./pkg/grpc

PROTOC_GEN_GO=$(shell command -v protoc-gen-go 2> /dev/null)
PROTOC_GEN_GO_GRPC=$(shell command -v protoc-gen-go-grpc 2> /dev/null)

.PHONY: proto run build clean check-tools install-tools update

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

run:
	go run main.go

build:
	go build -o $(APP_NAME) main.go

clean:
	rm -f $(APP_NAME)
	rm -f $(OUT_DIR)/*.pb.go

update:
	go mod tidy