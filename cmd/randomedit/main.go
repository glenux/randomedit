package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
)

func main() {
	list := []string{}
	err := filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		list = append(list, path)
		return nil
	})
	fmt.Printf("%#v\n", list)
	if err != nil {
		log.Println(err)
	}
}
