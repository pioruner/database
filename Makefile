APP_NAME=database

PROTOC=protoc
PROTO_FILES=$(wildcard *.proto)

.PHONY: proto run build clean

proto:
	$(PROTOC) --go_out=. --go-grpc_out=. \
		--go_opt=paths=source_relative \
		--go-grpc_opt=paths=source_relative \
		$(PROTO_FILES)

run:
	go run main.go

build:
	go build -o $(APP_NAME) main.go

clean:
	rm -f $(APP_NAME)
	rm -f *.pb.go