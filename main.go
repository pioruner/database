package main

import (
	"context"
	"log"
	"net"

	"github.com/pioruner/database/pkg/base"
	pb "github.com/pioruner/database/pkg/grpc"
	"google.golang.org/grpc"
)

type server struct {
	pb.UnimplementedTransferServiceServer
}

func (s *server) Ping(ctx context.Context, req *pb.PingRequest) (*pb.PingResponse, error) {
	log.Printf("Received Ping: %s", req.Msg)
	return &pb.PingResponse{Msg: "Pong: " + req.Msg}, nil
}

func main() {
	it := base.Item{ID: 1, Name: "1", Number: "1"}
	println(it.ID, it.Name, it.Number)

	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()
	pb.RegisterTransferServiceServer(grpcServer, &server{})

	log.Println("gRPC server is running on :50051")
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
