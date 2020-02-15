package main

import (
	// "flag"
	"fmt"
	flag "github.com/spf13/pflag"
	"log"
	"math/rand"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"time"
)

func findFiles(dir string, patterns []string) []string {
	files := []string{}
	err := filepath.Walk(dir, func(walkpath string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		for _, pattern := range patterns {
			if match, _ := path.Match(pattern, path.Base(walkpath)); match {
				// fmt.Printf("Pattern %s found %s\n", pattern, walkpath)
				files = append(files, walkpath)
			}
		}
		return nil
	})
	if err != nil {
		log.Panic(err)
	}
	return files
}

func main() {
	var directories []string
	var patterns []string
	flag.StringArrayVarP(&directories, "dir", "d", []string{"."}, "Look in given directory")
	flag.StringArrayVarP(&patterns, "pattern", "p", []string{}, "Match given globbing pattern")
	flag.Parse()

	if len(patterns) < 1 {
		patterns = []string{"*.txt", "*.md"}
	}

	// fmt.Printf("%#v\n", directories)
	editor := os.Getenv("EDITOR")

	// walk dirs & merge result
	filesSet := map[string]int{}
	for _, dir := range directories {
		for _, file := range findFiles(dir, patterns) {
			if _, ok := filesSet[file]; !ok {
				filesSet[file] = 0
			}
		}
	}

	// extract keys
	files := []string{}
	for k := range filesSet {
		files = append(files, k)
	}

	if len(files) < 1 {
		fmt.Println("No file found")
		os.Exit(1)
	}

	rand.Seed(time.Now().UTC().UnixNano())
	choice := rand.Intn(len(files))
	fmt.Printf("%s %s\n", editor, files[choice])

	// Run editor
	cmd := exec.Command(editor, files[choice])
	cmd.Stdout = os.Stdout
	cmd.Stdin = os.Stdin
	cmd.Stderr = os.Stderr
	cmd.Run()
}
