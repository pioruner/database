package main

import (
	"github.com/pioruner/database/pkg/base"
)

func main() {
	it := base.Item{ID: 1, Name: "1", Number: "1"}
	println(it.ID, it.Name, it.Number)
}
