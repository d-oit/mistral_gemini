#!/bin/bash

# Print commands and exit on errors
set -ex

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Please install Go first."
    exit 1
fi

# Create project directory if it doesn't exist
mkdir -p mistral-api-client

# Navigate to project directory
cd mistral-api-client

# Initialize Go module
go mod init mistral-api-client

# Install dependencies
go get github.com/joho/godotenv

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "MISTRAL_API_KEY=your_api_key_here" > .env
    echo "Created .env file. Please update it with your actual API key."
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo ".env" > .gitignore
    echo "Created .gitignore file."
fi

# Create main.go if it doesn't exist
if [ ! -f main.go ]; then
    cat > main.go << 'EOL'
package main

import (
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "os"

    "github.com/joho/godotenv"
)

const MISTRAL_API_URL = "https://api.mistral.ai/v1/models"

type Model struct {
    ID          string `json:"id"`
    Object      string `json:"object"`
    Created     int    `json:"created"`
    OwnedBy     string `json:"owned_by"`
    Permissions []any  `json:"permissions"`
}

type ModelsResponse struct {
    Object string  `json:"object"`
    Data   []Model `json:"data"`
}

func main() {
    // Load .env file
    if err := godotenv.Load(); err != nil {
        fmt.Printf("Error loading .env file: %v\n", err)
        return
    }

    // Get API key from environment
    apiKey := os.Getenv("MISTRAL_API_KEY")
    if apiKey == "" {
        fmt.Println("MISTRAL_API_KEY not found in environment")
        return
    }

    // Create new request
    req, err := http.NewRequest("GET", MISTRAL_API_URL, nil)
    if err != nil {
        fmt.Printf("Error creating request: %v\n", err)
        return
    }

    // Add headers
    req.Header.Add("Authorization", "Bearer "+apiKey)
    req.Header.Add("Content-Type", "application/json")

    // Make the request
    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        fmt.Printf("Error making request: %v\n", err)
        return
    }
    defer resp.Body.Close()

    // Read response body
    body, err := io.ReadAll(resp.Body)
    if err != nil {
        fmt.Printf("Error reading response: %v\n", err)
        return
    }

    // Check if response is successful
    if resp.StatusCode != http.StatusOK {
        fmt.Printf("Error: API returned status code %d\nResponse: %s\n", resp.StatusCode, string(body))
        return
    }

    // Parse JSON response
    var models ModelsResponse
    if err := json.Unmarshal(body, &models); err != nil {
        fmt.Printf("Error parsing JSON: %v\n", err)
        return
    }

    // Print models
    fmt.Println("Available Models:")
    fmt.Println("----------------")
    for _, model := range models.Data {
        fmt.Printf("ID: %s\n", model.ID)
        fmt.Printf("Object: %s\n", model.Object)
        fmt.Printf("Created: %d\n", model.Created)
        fmt.Printf("Owned By: %s\n", model.OwnedBy)
        fmt.Println("----------------")
    }
}
EOL
    echo "Created main.go file."
fi

# Make the script executable
chmod +x main.go

echo "Setup complete! Please update the .env file with your Mistral API key."
echo "To run the program, use: go run main.go"