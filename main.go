package main

import (
	"os"

	"github.com/8xu/envswitch/cmd"
)

func main() {
	if err := cmd.Root.Execute(); err != nil {
		os.Exit(1)
	}
}
