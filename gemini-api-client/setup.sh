#!/bin/bash

# Print commands and exit on errors
set -ex

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Please install Go first."
    exit 1
fi

# Create project directory if it doesn't exist
mkdir -p gemini-api-client

# Navigate to project directory
cd gemini-api-client

# Initialize Go module
go mod init gemini-api-client

# Install dependencies
go get github.com/joho/godotenv

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "GOOGLE_API_KEY=your_api_key_here" > .env
    echo "Created .env file. Please update it with your actual API key."
fi

# Create .gitignore if it doesn't exist
if [ ! -f .gitignore ]; then
    echo ".env" > .gitignore
    echo "logs/" >> .gitignore
    echo "Created .gitignore file."
fi

# Create main.go
cat > main.go << 'EOL'
package main

import (
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "os"
    "time"

    "github.com/joho/godotenv"
)

const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1/models"

type SafetySettings struct {
    Category       string `json:"category"`
    Threshold     string `json:"threshold"`
}

type LanguageModel struct {
    Name                    string   `json:"name"`
    Version                 string   `json:"version"`
    DisplayName            string   `json:"displayName"`
    Description           string    `json:"description"`
    InputTokenLimit       int      `json:"inputTokenLimit"`
    OutputTokenLimit      int      `json:"outputTokenLimit"`
    SupportedGenerationMethods []string `json:"supportedGenerationMethods"`
    Temperature            float64  `json:"temperature"`
    TopP                   float64  `json:"topP"`
    TopK                   int      `json:"topK"`
}

type ModelsResponse struct {
    Models []LanguageModel `json:"models"`
}

func main() {
    if err := godotenv.Load(); err != nil {
        fmt.Printf("Error loading .env file: %v\n", err)
        return
    }

    apiKey := os.Getenv("GOOGLE_API_KEY")
    if apiKey == "" {
        fmt.Println("GOOGLE_API_KEY not found in environment")
        return
    }

    requestURL := fmt.Sprintf("%s?key=%s", GEMINI_API_URL, apiKey)

    req, err := http.NewRequest("GET", requestURL, nil)
    if err != nil {
        fmt.Printf("Error creating request: %v\n", err)
        return
    }

    req.Header.Add("Content-Type", "application/json")

    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        fmt.Printf("Error making request: %v\n", err)
        return
    }
    defer resp.Body.Close()

    body, err := io.ReadAll(resp.Body)
    if err != nil {
        fmt.Printf("Error reading response: %v\n", err)
        return
    }

    // Create logs directory if it doesn't exist
    if err := os.MkdirAll("logs", 0755); err != nil {
        fmt.Printf("Error creating logs directory: %v\n", err)
        return
    }

    // Log raw response
    timestamp := time.Now().Format("2006-01-02_15-04-05")
    logFile := fmt.Sprintf("logs/gemini_api_response_%s.json", timestamp)
    if err := os.WriteFile(logFile, body, 0644); err != nil {
        fmt.Printf("Error writing log file: %v\n", err)
        return
    }

    if resp.StatusCode != http.StatusOK {
        fmt.Printf("Error: API returned status code %d\nResponse: %s\n", resp.StatusCode, string(body))
        return
    }

    var models ModelsResponse
    if err := json.Unmarshal(body, &models); err != nil {
        fmt.Printf("Error parsing JSON: %v\n", err)
        return
    }

    fmt.Println("Available Gemini Models:")
    fmt.Println("------------------------")
    for _, model := range models.Models {
        fmt.Printf("Name: %s\n", model.Name)
        fmt.Printf("Version: %s\n", model.Version)
        fmt.Printf("Display Name: %s\n", model.DisplayName)
        fmt.Printf("Description: %s\n", model.Description)
        fmt.Printf("Input Token Limit: %d\n", model.InputTokenLimit)
        fmt.Printf("Output Token Limit: %d\n", model.OutputTokenLimit)
        fmt.Printf("Temperature: %.2f\n", model.Temperature)
        fmt.Printf("Top P: %.2f\n", model.TopP)
        fmt.Printf("Top K: %d\n", model.TopK)
        fmt.Printf("Supported Generation Methods: %v\n", model.SupportedGenerationMethods)
        fmt.Println("------------------------")
    }
}
EOL

# Make the script executable
chmod +x main.go

echo "Setup complete! Please update the .env file with your Google API key."
echo "To run the program, use: go run main.go"