#!/bin/bash
set -e

echo "Setting up Llmzy Speech development environment..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js 20.x before continuing."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "Node.js version 20.x or higher is required. Current version: $(node -v)"
    echo "Please upgrade Node.js before continuing."
    exit 1
fi

# Install system dependencies based on OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Installing Linux dependencies..."
    sudo apt-get update
    sudo apt-get install -y alsa-utils
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Installing macOS dependencies..."
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Please install Homebrew first: https://brew.sh/"
        exit 1
    fi
    brew install sox
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    echo "On Windows, please manually install SoX from: https://sourceforge.net/projects/sox/files/sox/"
    echo "After installation, ensure SoX is in your PATH."
fi

# Set up .npmrc from secret directly in bash
echo "Setting up .npmrc from secret..."
NPMRC_PATH="$HOME/.npmrc"

if [ -n "$NPMRC" ]; then
  echo "Found NPMRC secret in environment variables"
  # Write the secret to the .npmrc file, properly handling newlines
  echo -e "$NPMRC" > "$NPMRC_PATH"
  # Set permissions to be readable only by the owner
  chmod 600 "$NPMRC_PATH"
  echo "✅ Successfully created .npmrc file at $NPMRC_PATH"
else
  echo "⚠️ NPMRC secret not found in environment variables"
  
  # Check if .npmrc already exists
  if [ -f "$NPMRC_PATH" ]; then
    echo "Using existing .npmrc file at $NPMRC_PATH"
  else
    echo "❌ No .npmrc file found and no NPMRC secret available"
    echo "Please configure the NPMRC secret in the OpenHands UI"
    echo "The setup will continue, but you may need to configure your .npmrc manually later."
  fi
fi

# Test the .npmrc by installing @llmzy/cli globally
echo "Testing .npmrc by installing @llmzy/cli globally..."
if npm install -g @llmzy/cli; then
  echo "✅ Successfully installed @llmzy/cli globally"
  
  # Test the installation by running llmzy --help
  echo "Testing the installation by running llmzy --help..."
  if llmzy --help; then
    echo "✅ Successfully ran llmzy --help"
  else
    echo "⚠️ Warning: Failed to run llmzy --help, but continuing with setup"
  fi
else
  echo "⚠️ Warning: Failed to install @llmzy/cli globally"
  echo "This might be due to permission issues with your .npmrc configuration."
  echo "The setup will continue, but you may need to configure your .npmrc manually later."
fi

# Install npm dependencies
echo "Installing npm dependencies..."
if npm ci; then
  echo "✅ Successfully installed npm dependencies"
  
  # Build the project
  echo "Building the project..."
  if npm run build; then
    echo "✅ Successfully built the project"
  else
    echo "⚠️ Warning: Failed to build the project"
    echo "You may need to fix any issues and run 'npm run build' again."
  fi
else
  echo "⚠️ Warning: Failed to install npm dependencies"
  echo "This might be due to permission issues with your .npmrc configuration."
  echo "Please make sure your .npmrc file is correctly set up with the necessary authentication token."
  echo ""
  echo "To manually set up your .npmrc file:"
  echo "1. Make sure you have the NPMRC secret configured in the OpenHands UI"
  echo "2. The secret should contain the necessary configuration for @llmzy packages"
  echo "3. Run the setup script again after configuring the secret"
fi

export GITHUB_WORKFLOW=true
echo "✅ Setting GITHUB_WORKFLOW to skip tests that cannot run without mic or speakers"
echo ""

echo "Setup complete!"
echo "Next run the build with:"
echo "  npm run build"
echo ""
echo "Then run tests with:"
echo "  npm run test:coverage"
echo ""
echo "Finally, test the commands:"
echo "  ./bin/dev.js                  # displays help"
echo "  ./bin/dev.js speech           # list available speech commands"
echo "  ./bin/dev.js speech providers # displays available providers"
echo ""
echo "For more information, see the documentation in the doc/ directory."
