# AI Model API Clients

This repository contains Go clients for interacting with Mistral AI and Google's Gemini API services. These clients allow you to query available models and their capabilities.

## Prerequisites

- Go 1.24 or higher
- API keys for the services you want to use:
  - Mistral AI API key (get it from [Mistral AI Platform](https://console.mistral.ai/))
  - Google API key (get it from [Google AI Studio](https://makersuite.google.com/app/apikey))

## Installation

1. Clone the repository:
```bash
git clone [your-repository-url]
```

2. Choose the client you want to use:

### Mistral API Client
```bash
cd mistral-api-client
./setup.sh
cp .env.example .env  # Create your .env file from the example
```

### Gemini API Client
```bash
cd gemini-api-client
./setup.sh
cp .env.example .env  # Create your .env file from the example
```

3. Configure your API keys:

For Mistral API:
```env
# mistral-api-client/.env
MISTRAL_API_KEY=your_mistral_api_key_here
```

For Gemini API:
```env
# gemini-api-client/.env
GOOGLE_API_KEY=your_google_api_key_here
```

## Usage

### Mistral API Client
```bash
cd mistral-api-client
go run main.go
```

The Mistral client will:
- List all available models
- Show model capabilities (chat, vision, function calling, etc.)
- Display context lengths and default parameters
- Generate a TypeScript-compatible model description file

### Gemini API Client
```bash
cd gemini-api-client
go run main.go
```

The Gemini client will:
- List all available models
- Show model parameters (token limits, temperature, etc.)
- Display supported generation methods

## Features

### Common Features
- Environment variable management using `.env` files
- JSON response logging
- Detailed model information display

### Mistral-specific Features
- Comprehensive model capabilities reporting
- TypeScript model description generation
- Support for various model types (chat, vision, code)

### Gemini-specific Features
- Token limit information
- Generation method details
- Safety settings support

## Project Structure

```
.
├── mistral-api-client/
│   ├── main.go
│   ├── setup.sh
│   ├── .env.example
│   ├── .env           (created from .env.example)
│   └── logs/
└── gemini-api-client/
    ├── main.go
    ├── setup.sh
    ├── .env.example
    ├── .env           (created from .env.example)
    └── logs/
```

## Security

- API keys are stored in `.env` files
- Never commit your actual `.env` files to git (they are excluded via `.gitignore`)
- Only commit `.env.example` files with placeholder values
- All API requests use secure HTTPS endpoints
- Regularly rotate your API keys for better security

## Environment Variables

### Mistral API Client
- `MISTRAL_API_KEY`: Your Mistral AI API key
  - Required for authentication
  - Get it from the [Mistral AI Platform](https://console.mistral.ai/)
  - Example format: `mist_xxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Gemini API Client
- `GOOGLE_API_KEY`: Your Google API key
  - Required for authentication
  - Get it from [Google AI Studio](https://makersuite.google.com/app/apikey)
  - Example format: `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`

## License

[Your chosen license]

## Contributing

[Your contribution guidelines]
