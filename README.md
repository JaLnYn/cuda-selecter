# CUDA Setup Script

Simple CUDA version switcher.

## What it does

- Finds all CUDA versions on your system
- Lets you pick one
- Sets it up immediately 
- Adds to venv if you're in one

## Usage

One-liner:
```bash
bash <(curl -s https://raw.githubusercontent.com/JaLnYn/cuda-selecter/main/cuda-selecter.sh)
```

Or download and run:
```bash
wget https://raw.githubusercontent.com/JaLnYn/cuda-selecter/main/cuda-selecter.sh
chmod +x cuda-selecter.sh
./cuda-selecter.sh
```

Pick your version:
```
Found CUDA installations:
   1. cuda-12.4 (/usr/local/cuda-12.4)
   2. cuda-12.6 (/usr/local/cuda-12.6)
   3. cuda (/usr/local/cuda)

Enter the number of your choice: 2
```

CUDA 12.6 is now active.

Config has also been added to your activate script in your virtual environment. 

## Requirements

- CUDA installed in `/usr/local/cuda-*`
- Bash shell


