#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════╗"
echo "║           NADEEM TOOL INSTALLER         ║"
echo "║           Auto-Installation Script      ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running in Termux
if [ ! -d "/data/data/com.termux/files/usr" ]; then
    echo -e "${RED}❌ Error: This script must be run in Termux${NC}"
    exit 1
fi

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Success${NC}"
    else
        echo -e "${RED}❌ Failed${NC}"
    fi
}

# Setup Termux storage if not already done
echo -e "${YELLOW}[1] Setting up Termux storage...${NC}"
if [ ! -d ~/storage ]; then
    termux-setup-storage
    echo -e "${YELLOW}Please grant storage permission when prompted${NC}"
    sleep 2
else
    echo -e "${GREEN}✅ Storage already set up${NC}"
fi

# Update packages
echo -e "${YELLOW}[2] Updating packages...${NC}"
pkg update -y
check_success

# Install dependencies
echo -e "${YELLOW}[3] Installing dependencies...${NC}"
pkg install -y python git wget unzip -o Dpkg::Options::="--force-confnew"
check_success

# Navigate to NADEEM directory
echo -e "${YELLOW}[4] Preparing NADEEM directory...${NC}"
mkdir -p ~/NADEEM
cd ~/NADEEM

# Show existing files before update
echo -e "${CYAN}📂 Existing files in ~/NADEEM/:${NC}"
ls -la

# Download the NEW tool
echo -e "${YELLOW}[5] Downloading NADEEM tool...${NC}"
rm -f 4.2_TOOL.zip  # Remove old zip file only
wget -O 4.2_TOOL.zip https://github.com/yellowbodygg-hub/TOOL_4.2/raw/main/4.2_TOOL.zip

if [ ! -f "4.2_TOOL.zip" ]; then
    echo -e "${RED}❌ Error: Failed to download the tool${NC}"
    exit 1
fi
check_success

# Extract NEW files (overwrites duplicates)
echo -e "${YELLOW}[6] Extracting files (overwrites duplicates)...${NC}"
unzip -o 4.2_TOOL.zip
rm -f 4.2_TOOL.zip
check_success

echo -e "${CYAN}📂 Files after extraction:${NC}"
ls -la

# Make sure ND_TOOL is executable
echo -e "${YELLOW}[7] Setting up ND_TOOL executable...${NC}"

if [ -f "ND_TOOL" ]; then
    chmod +x ND_TOOL
    echo -e "${GREEN}✅ ND_TOOL is now executable${NC}"
    
    # Test ND_TOOL
    echo -e "${CYAN}Testing ND_TOOL...${NC}"
    if ./ND_TOOL --version 2>/dev/null || ./ND_TOOL -h 2>/dev/null; then
        echo -e "${GREEN}✅ ND_TOOL is working${NC}"
    else
        echo -e "${YELLOW}⚠️  ND_TOOL executed${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  ND_TOOL file not found, searching for alternatives...${NC}"
    
    # Look for any executable
    if ls tool* 1>/dev/null 2>&1; then
        TOOL_FILE=$(ls tool* | head -1)
        echo -e "${YELLOW}Found $TOOL_FILE, renaming to ND_TOOL...${NC}"
        mv "$TOOL_FILE" ND_TOOL
        chmod +x ND_TOOL
        echo -e "${GREEN}✅ Created ND_TOOL from $TOOL_FILE${NC}"
    elif ls *.py 1>/dev/null 2>&1; then
        PY_FILE=$(ls *.py | head -1)
        echo -e "${YELLOW}Creating Python launcher for $PY_FILE...${NC}"
        cat > ND_TOOL << EOF
#!/bin/bash
cd ~/NADEEM
python $PY_FILE "\$@"
EOF
        chmod +x ND_TOOL
        echo -e "${GREEN}✅ Created Python launcher ND_TOOL${NC}"
    fi
fi

# Install Python modules
echo -e "${YELLOW}[8] Installing Python modules...${NC}"
pip install requests rich colorama tqdm pycryptodome zstandard gmalg 2>/dev/null || echo -e "${YELLOW}[!] Some modules skipped${NC}"

# Create system-wide ND_TOOL command
echo -e "${YELLOW}[9] Creating ND_TOOL command...${NC}"

# Create command
cat > $PREFIX/bin/ND_TOOL << 'EOF'
#!/bin/bash
cd ~/NADEEM
if [ -f "./ND_TOOL" ]; then
    exec ./ND_TOOL "$@"
else
    echo "Error: ND_TOOL not found in ~/NADEEM/"
    echo "Available files:"
    ls -la ~/NADEEM/
    exit 1
fi
EOF

chmod +x $PREFIX/bin/ND_TOOL
echo -e "${GREEN}✅ Created ND_TOOL system command${NC}"

# Update aliases
echo -e "${YELLOW}[10] Updating aliases...${NC}"
sed -i '/alias ND_TOOL/d' ~/.bashrc 2>/dev/null
echo "alias ND_TOOL='cd ~/NADEEM && ./ND_TOOL'" >> ~/.bashrc

if [ -f ~/.zshrc ]; then
    sed -i '/alias ND_TOOL/d' ~/.zshrc 2>/dev/null
    echo "alias ND_TOOL='cd ~/NADEEM && ./ND_TOOL'" >> ~/.zshrc
fi

# Refresh shell
source ~/.bashrc 2>/dev/null

# Display completion message
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║           INSTALLATION COMPLETE!        ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "${GREEN}🎉 NADEEM Tool successfully installed/updated!${NC}"
echo ""
echo -e "${CYAN}📁 Installation Location:${NC}"
echo -e "${GREEN}   ~/NADEEM/${NC}"
echo ""
echo -e "${CYAN}📂 Current Files:${NC}"
ls -la ~/NADEEM/
echo ""
echo -e "${CYAN}🔄 UPDATE PROCESS:${NC}"
echo -e "${GREEN}   • Downloaded latest version${NC}"
echo -e "${GREEN}   • Extracted files (overwrote duplicates)${NC}"
echo -e "${GREEN}   • Preserved existing files${NC}"
echo -e "${GREEN}   • Kept ND_TOOL as main executable${NC}"
echo ""
echo -e "${CYAN}🚀 HOW TO RUN THE TOOL:${NC}"
echo -e "${GREEN}   Simply type: ${CYAN}ND_TOOL${GREEN} and press Enter${NC}"
echo ""
echo -e "${GREEN}   Or: ${CYAN}cd ~/NADEEM && ./ND_TOOL${NC}"
echo ""
echo -e "${GREEN}💡 Type ${CYAN}ND_TOOL${GREEN} anywhere in Termux to run your tool!${NC}"