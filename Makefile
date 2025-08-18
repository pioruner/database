APP_NAME=database
PROTOC=protoc
PROTO_FILE=proto.proto
PROTO_PATH=.
OUT_DIR=./pkg/grpc

.PHONY: proto run build clean

proto:
	$(PROTOC) --proto_path=$(PROTO_PATH) \
		--go_out=$(OUT_DIR) --go-grpc_out=$(OUT_DIR) \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative \
		$(PROTO_FILE)

run:
	go run main.go

build:
	go build -o $(APP_NAME) main.go

clean:
	rm -f $(APP_NAME)
	rm -f $(OUT_DIR)/*.pb.go