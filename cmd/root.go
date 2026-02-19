package cmd

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

var Root = &cobra.Command{
	Use:   "envswitch",
	Short: "Quickly switch between .env files",
}

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "List available environments",
	Run:   listEnvs,
}

var switchCmd = &cobra.Command{
	Use:   "switch [env-name]",
	Short: "Switch to an environment",
	Args:  cobra.ExactArgs(1),
	Run:   switchEnv,
}

func init() {
	Root.CompletionOptions.DisableDefaultCmd = true
	Root.AddCommand(listCmd)
	Root.AddCommand(switchCmd)
}

func listEnvs(cmd *cobra.Command, args []string) {
	envDir := findEnvDir()
	if envDir == "" {
		fmt.Println("No .envs directory found")
		os.Exit(1)
	}

	entries, err := os.ReadDir(envDir)
	if err != nil {
		fmt.Printf("Error reading directory: %v\n", err)
		os.Exit(1)
	}

	fmt.Println("Available environments:")
	for _, e := range entries {
		if !e.IsDir() && strings.HasPrefix(e.Name(), ".env") {
			name := strings.TrimPrefix(e.Name(), ".env")
			if name == "" {
				name = "default"
			} else {
				name = strings.TrimPrefix(name, ".")
			}
			fmt.Printf("  %s\n", name)
		}
	}
}

func switchEnv(cmd *cobra.Command, args []string) {
	envName := args[0]
	envDir := findEnvDir()

	if envDir == "" {
		fmt.Println("No .envs directory found")
		os.Exit(1)
	}

	envFile := filepath.Join(envDir, ".env."+envName)
	if _, err := os.Stat(envFile); err != nil {
		fmt.Printf("Environment '%s' not found\n", envName)
		os.Exit(1)
	}

	target := ".env"
	if _, err := os.Stat(target); err == nil {
		backup := ".env.backup"
		os.Rename(target, backup)
		fmt.Printf("Backed up current .env to .env.backup\n")
	}

	if err := os.Symlink(envFile, target); err != nil {
		fmt.Printf("Error creating symlink: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Switched to '%s' environment\n", envName)
}

func findEnvDir() string {
	dirs := []string{".envs", "envs", "environments"}
	for _, d := range dirs {
		if _, err := os.Stat(d); err == nil {
			return d
		}
	}

	home, _ := os.UserHomeDir()
	for _, d := range dirs {
		path := filepath.Join(home, ".config", "envswitch", d)
		if _, err := os.Stat(path); err == nil {
			return path
		}
	}

	return ""
}
