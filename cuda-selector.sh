#!/bin/bash

# Script to set CUDA environment variables globally or in virtual environment

# Function to find CUDA versions
find_cuda_versions() {
    local cuda_dirs=()
    
    # Search for CUDA directories in /usr/local
    for dir in /usr/local/cuda-*; do
        if [[ -d "$dir" && -d "$dir/bin" ]]; then
            cuda_dirs+=("$dir")
        fi
    done
    
    # Also check if /usr/local/cuda exists (default symlink)
    if [[ -d "/usr/local/cuda" && -d "/usr/local/cuda/bin" ]]; then
        cuda_dirs+=("/usr/local/cuda")
    fi
    
    echo "${cuda_dirs[@]}"
}

# Function to set CUDA environment variables immediately
set_cuda_env() {
    local cuda_path="$1"
    export CUDA_HOME="$cuda_path"
    export PATH="$cuda_path/bin:$PATH"
    export LD_LIBRARY_PATH="$cuda_path/lib64:$LD_LIBRARY_PATH"
    echo "✅ CUDA environment variables set for current session:"
    echo "   CUDA_HOME=$CUDA_HOME"
    echo "   PATH updated to include $cuda_path/bin"
    echo "   LD_LIBRARY_PATH updated to include $cuda_path/lib64"
}

# Function to add CUDA to virtual environment
add_cuda_to_venv() {
    local cuda_path="$1"
    local activate_script="$VIRTUAL_ENV/bin/activate"
    
    # Check if CUDA config already exists
    if grep -q "### cuda-version-script" "$activate_script"; then
        echo "⚠️  CUDA configuration already exists in virtual environment."
        echo "   Remove existing configuration manually if you want to change versions."
        return 1
    fi
    
    # Backup original activate script
    cp "$activate_script" "$activate_script.backup"
    
    # Add CUDA environment variables to the activate script
    cat >> "$activate_script" << EOF

### cuda-version-script
# CUDA Environment Variables
export CUDA_HOME="$cuda_path"
export PATH="$cuda_path/bin:\$PATH"
export LD_LIBRARY_PATH="$cuda_path/lib64:\$LD_LIBRARY_PATH"
### cuda-version-script
EOF
    
    echo "✅ CUDA configuration added to virtual environment."
    echo "📝 Original activate script backed up as: $activate_script.backup"
    echo ""
    echo "To apply in future sessions, deactivate and reactivate your environment:"
    echo "   deactivate && source $VIRTUAL_ENV/bin/activate"
    
    return 0
}

# Main script
echo "🔍 Searching for CUDA installations in /usr/local..."

# Find available CUDA versions
cuda_versions=($(find_cuda_versions))

if [[ ${#cuda_versions[@]} -eq 0 ]]; then
    echo "❌ No CUDA installations found in /usr/local"
    echo "   Expected directories like: /usr/local/cuda-12.4, /usr/local/cuda-12.6, etc."
    exit 1
fi

echo "📋 Found CUDA installations:"
for i in "${!cuda_versions[@]}"; do
    version_name=$(basename "${cuda_versions[$i]}")
    echo "   $((i+1)). $version_name (${cuda_versions[$i]})"
done

# Get user selection
echo ""
read -p "Enter the number of your choice: " choice

# Validate choice
if [[ ! "$choice" =~ ^[0-9]+$ ]] || [[ "$choice" -lt 1 ]] || [[ "$choice" -gt ${#cuda_versions[@]} ]]; then
    echo "❌ Invalid selection. Please enter a number between 1 and ${#cuda_versions[@]}"
    exit 1
fi

# Get selected CUDA path
selected_cuda="${cuda_versions[$((choice-1))]}"
selected_version=$(basename "$selected_cuda")

echo ""
echo "🎯 Selected: $selected_version ($selected_cuda)"

# Verify CUDA installation
if [[ ! -d "$selected_cuda/bin" ]]; then
    echo "❌ Invalid CUDA installation: $selected_cuda/bin not found"
    exit 1
fi

# Set CUDA environment variables for current session
set_cuda_env "$selected_cuda"

# Check if we're in a virtual environment
if [[ -n "$VIRTUAL_ENV" ]]; then
    echo ""
    echo "🐍 Virtual environment detected: $VIRTUAL_ENV"
    
    if add_cuda_to_venv "$selected_cuda"; then
        echo ""
        echo "🎉 CUDA $selected_version configured for both current session and virtual environment!"
    else
        echo ""
        echo "🎉 CUDA $selected_version configured for current session only."
        echo "   (Virtual environment already has CUDA configuration)"
    fi
else
    echo ""
    echo "🎉 CUDA $selected_version configured for current session!"
    echo "   Note: No virtual environment detected. Changes apply to current session only."
    echo "   To make permanent, add the export commands to your ~/.bashrc or ~/.zshrc"
fi

echo ""
echo "🔧 Verify installation:"
echo "   nvcc --version"
echo "   nvidia-smi"
