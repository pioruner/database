package main

import "github.com/pioruner/database/pkg/transfer"

func main() {
	it := transfer.Item{ID: 1, Name: "1", Number: "1"}
	println(it.Name)
}
