package main

import (
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "os"
    "strings"
    "time"

    "github.com/joho/godotenv"
)

const MISTRAL_API_URL = "https://api.mistral.ai/v1/models"

type Capabilities struct {
    CompletionChat   bool `json:"completion_chat"`
    CompletionFim    bool `json:"completion_fim"`
    FunctionCalling  bool `json:"function_calling"`
    FineTuning      bool `json:"fine_tuning"`
    Vision          bool `json:"vision"`
}

type Model struct {
    ID                    string      `json:"id"`
    Object                string      `json:"object"`
    Created               int         `json:"created"`
    OwnedBy               string      `json:"owned_by"`
    Capabilities          Capabilities `json:"capabilities"`
    Name                  string      `json:"name"`
    Description           string      `json:"description"`
    MaxContextLength      int         `json:"max_context_length"`
    Aliases               []string    `json:"aliases"`
    Deprecation           interface{} `json:"deprecation"`
    DefaultModelTemperature float64    `json:"default_model_temperature"`
    Type                  string      `json:"type"`
}

type ModelsResponse struct {
    Object string  `json:"object"`
    Data   []Model `json:"data"`
}

type ModelInfo struct {
    MaxTokens            int     `json:"maxTokens"`
    ContextWindow        int     `json:"contextWindow"`
    SupportsImages      bool    `json:"supportsImages"`
    SupportsPromptCache bool    `json:"supportsPromptCache"`
    DefaultTemperature  float64 `json:"defaultTemperature"`
}

func generateModelDescription(models ModelsResponse) error {
    var output strings.Builder
    
    output.WriteString("export const mistralDefaultModelId: MistralModelId = \"mistral-large-latest\"\n\n")
    output.WriteString("export const mistralModels = {\n")
    
    for _, model := range models.Data {
        // Skip if model doesn't have required capabilities or doesn't end with "-latest"
        if !model.Capabilities.CompletionChat || !strings.HasSuffix(model.ID, "-latest") {
            continue
        }
        
        output.WriteString(fmt.Sprintf("\t\"%s\": {\n", model.ID))
        output.WriteString(fmt.Sprintf("\t\tmaxTokens: %d,\n", model.MaxContextLength))
        output.WriteString(fmt.Sprintf("\t\tcontextWindow: %d,\n", model.MaxContextLength))
        output.WriteString(fmt.Sprintf("\t\tsupportsImages: %t,\n", model.Capabilities.Vision))
        output.WriteString("\t\tsupportsPromptCache: false,\n")
        output.WriteString(fmt.Sprintf("\t\tdefaultTemperature: %.2f,\n", model.DefaultModelTemperature))
        output.WriteString("\t},\n")
    }
    
    output.WriteString("} as const satisfies Record<string, ModelInfo>\n")
    
    // Write to file
    return os.WriteFile("mistralDescription.txt", []byte(output.String()), 0644)
}

func main() {
    if err := godotenv.Load(); err != nil {
        fmt.Printf("Error loading .env file: %v\n", err)
        return
    }

    apiKey := os.Getenv("MISTRAL_API_KEY")
    if apiKey == "" {
        fmt.Println("MISTRAL_API_KEY not found in environment")
        return
    }

    req, err := http.NewRequest("GET", MISTRAL_API_URL, nil)
    if err != nil {
        fmt.Printf("Error creating request: %v\n", err)
        return
    }

    req.Header.Add("Authorization", "Bearer "+apiKey)
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
    logFile := fmt.Sprintf("logs/mistral_api_response_%s.json", timestamp)
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

    fmt.Println("Available Models:")
    fmt.Println("----------------")
    for _, model := range models.Data {
        fmt.Printf("ID: %s\n", model.ID)
        fmt.Printf("Name: %s\n", model.Name)
        fmt.Printf("Description: %s\n", model.Description)
        fmt.Printf("Type: %s\n", model.Type)
        fmt.Printf("Max Context Length: %d\n", model.MaxContextLength)
        fmt.Printf("Default Temperature: %.2f\n", model.DefaultModelTemperature)
        fmt.Printf("Capabilities:\n")
        fmt.Printf("  - Chat Completion: %t\n", model.Capabilities.CompletionChat)
        fmt.Printf("  - FIM: %t\n", model.Capabilities.CompletionFim)
        fmt.Printf("  - Function Calling: %t\n", model.Capabilities.FunctionCalling)
        fmt.Printf("  - Fine Tuning: %t\n", model.Capabilities.FineTuning)
        fmt.Printf("  - Vision: %t\n", model.Capabilities.Vision)
        if len(model.Aliases) > 0 {
            fmt.Printf("Aliases: %v\n", model.Aliases)
        }
        fmt.Println("----------------")
    }

    if err := generateModelDescription(models); err != nil {
        fmt.Printf("Error generating model description: %v\n", err)
        return
    }

    fmt.Println("Model description generated successfully.")
}
