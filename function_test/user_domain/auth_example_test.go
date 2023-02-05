package userdomainclient

import (
	"context"
	"fmt"

	pb "github.com/sean0427/micro-service-pratice-auth-domain/userdomainclient/grpc/auth"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func createGrpcClient(addr string) (*grpc.ClientConn, error) {
	conn, err := grpc.Dial(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		return nil, err
	}

	return conn, nil
}

func ExampleAuthClient_Authenticate() {
	conn, err := createGrpcClient(":50051")

	if err != nil {
		panic(err)
	}
	defer conn.Close()
	userClient := pb.NewAuthClient(conn)

	r, err := userClient.Authenticate(context.TODO(), &pb.AuthRequest{
		Name:     "11",
		Password: "11",
	})
	fmt.Println(r, err)

	client := New(userClient)

	ret, err := client.Authenticate(context.Background(), "11", "11")

	fmt.Printf("A: %v, %v\n", ret, err)
}
