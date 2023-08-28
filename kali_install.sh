#!/bin/bash

install_static_packages() {
    echo ""
    echo "******************************"
    echo "* Installing Static Packages *"
    echo "******************************"
    echo ""
    mkdir -p /tmp/debs/

    # Installing Obsidian #
    echo "Checking for latest Obsidian release version..."
    OBSIDIAN_URL=$(wget -q -O - https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep 'deb"$' | awk -F'"' ' {print $4} ')

    if [ "$(dpkg -s obsidian | grep Version | cut -d' ' -f2)" = "$(echo $OBSIDIAN_URL | cut -d'/' -f8 | cut -dv -f2)" ]; then
        echo "Obsidian is installed and is the correct version, moving on..."
    else
        OBSIDIAN_DEB_FILEPATH=/tmp/debs/$(echo $OBSIDIAN_URL | cut -d'/' -f9)
        if [ ! -f "$OBSIDIAN_DEB_FILEPATH" ]; then
            echo "Downloading most up to date Obsidian version from $OBSIDIAN_URL..."
            wget -q -P /tmp/debs/ $OBSIDIAN_URL
        else
            echo "Using cached Obsidian deb at $OBSIDIAN_DEB_FILEPATH..."
        fi

        echo "Installing Obsidian..."
        sudo dpkg -i $OBSIDIAN_DEB_FILEPATH > /dev/null 2>&1
    fi
    # Installing Obsidian #

    # Installing VSCode #
    echo "Checking for latest VSCode release version..."
    VSCODE_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} https://code.visualstudio.com/updates/ | cut -d/ -f5 | cut -dv -f2 | sed -En 's/_/\./p')

    if [ "$(echo $(dpkg -s code | grep Version | cut -d' ' -f2 | head -c $(expr length $VSCODE_VERSION)))" = "$VSCODE_VERSION" ]; then
        echo "VSCode is installed and is the correct version, moving on..."
    else
        VSCODE_DEB_FILEPATH=/tmp/debs/vscode_$VSCODE_VERSION.deb
        if [ ! -f "$VSCODE_DEB_FILEPATH" ]; then
            VSCODE_URL=https://code.visualstudio.com/sha/download?build=stable\&os=linux-deb-x64
            echo "Downloading most up to date VSCode version from $VSCODE_URL..."
            wget -q -O $VSCODE_DEB_FILEPATH $VSCODE_URL
        else
            echo "Using cached VSCode deb at $VSCODE_DEB_FILEPATH..."
        fi

        echo "Installing VSCode..."
        sudo dpkg -i $VSCODE_DEB_FILEPATH > /dev/null 2>&1
    fi
    # Installing VSCode #

    echo ""
    echo "* Done Installing Static Packages *"
    echo ""
}

install_python_tools() {
    echo ""
    echo "***************************"
    echo "* Installing Python Tools *"
    echo "***************************"
    echo ""
    mkdir -p ~/tools/

    # Installing Autorecon #
    if ! command -v autorecon &> /dev/null
    then
        echo "autorecon not found, installing...."
        echo "Gathering and installing all apt dependencies..."
        sudo apt install python3 python3-pip python3-venv seclists curl dnsrecon enum4linux feroxbuster gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf > /dev/null 2>&1
        echo "Setting up pipx environment..."
        python3 -m pip install --user pipx > /dev/null 2>&1
        python3 -m pipx ensurepath > /dev/null 2>&1
        echo "Installing autorecon..."
        zsh -c 'python3 -m pipx install git+https://github.com/Tib3rius/AutoRecon.git' > /dev/null 2>&1
    else
        echo "autrecon found, attempting to upgrade..."
        zsh -c 'python3 -m pipx upgrade autorecon' > /dev/null 2>&1
    fi
    
    # Installing Autorecon #

    echo ""
    echo "* Done Installing Python Tools *"
    echo ""
}

# sudo apt update
install_static_packages
install_python_tools
