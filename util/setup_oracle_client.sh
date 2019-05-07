apt_install_oracle_client() {
  if [ ! -s /opt/oracle/instantclient_12_1 ]; then
    echo "Installing oracle..."
    ##### (Cosmetic) Colour output
    red=$(tput setaf 1)      # Issues/Errors
    green=$(tput setaf 2)    # Success
    yellow=$(tput setaf 3)   # Warnings/Information
    blue=$(tput setaf 4)     # Heading
    bold=$(tput bold  setaf 7)     # Highlight
    reset=$(tput setaf 7)       # Normal

    instdir=/opt/oracle/instantclient_12_1
    sudo apt-get install libaio1
    sudo mkdir -p /opt/oracle/
    echo -e "${green}[*]${reset} Extracting instant-basic-linux to /opt/oracle/"
    sudo unzip -qq $HOME/dotfiles/files/oracle/instantclient-basic-linux.*.zip -d /opt/oracle/ || echo -e ' '${red}'[!] Error extracting instantclient-basic-linux'${reset} 1>&2

    echo -e "${green}[*]${reset} Extracting instantclient-sdk-linux to /opt/oracle/"
    sudo unzip -qq $HOME/dotfiles/files/oracle/instantclient-sdk-linux.*.zip -d /opt/oracle/ || echo -e ' '${red}'[!] Error extracting instantclient-sdk-linux'${reset} 1>&2

    echo -e "${green}[*]${reset} Extracting instantclient-basic-linux to /opt/oracle/"
    sudo unzip -qq $HOME/dotfiles/files/oracle/instantclient-sqlplus-linux.*.zip -d /opt/oracle/ || echo -e ' '${red}'[!] Error extracting instantclient-sqlplus-linux'${reset} 1>&2

    if [ ! -f $instdir/libclntsh.so ]; then
        sudo ln -sf $instdir/libclntsh.so.12.1 $instdir/libclntsh.so || echo -e ' '${red}'[!] Error creating symlink '${reset}
    fi
    # Configure environment variables in ~/.zshrc
    # If they don't already exist add them...

    echo -e "${green}[*]${reset} Configuring environment variables in ~/.bashrc"

    grep -q -e '# ORACLE Stuff' ~/.zshrc || echo -e "# ORACLE Stuff" >> ~/.bashrc
    grep -q -e 'PATH=$PATH:/opt/oracle/instantclient_12_1' ~/.zshrc || echo -e 'PATH=$PATH:/opt/oracle/instantclient_12_1' >> ~/.zshrc
    grep -q -e 'SQLPATH=/opt/oracle/instantclient_12_1' ~/.zshrc || echo -e "SQLPATH=/opt/oracle/instantclient_12_1" >> ~/.zshrc
    grep -q -e 'TNS_ADMIN=/opt/oracle/instantclient_12_1' ~/.zshrc || echo -e "TNS_ADMIN=/opt/oracle/instantclient_12_1" >> ~/.zshrc
    grep -q -e 'LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1' ~/.zshrc || echo -e "LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1" >> ~/.zshrc
    grep -q -e 'ORACLE_HOME=/opt/oracle/instantclient_12_1' ~/.zshrc || echo -e "ORACLE_HOME=/opt/oracle/instantclient_12_1" >> ~/.zshrc
    grep -q -e '# Set path to correct version of ruby for metasploit' ~/.zshrc || echo -e "# Set path to correct version of ruby for metasploit" >> ~/.zshrc
    grep -q -e 'PATH=/opt/metasploit/ruby/bin:$PATH' ~/.zshrc || echo -e 'PATH=/opt/metasploit/ruby/bin:$PATH'>> ~/.zshrc

    # Set environment variables for current shell session
    echo -e "${green}[*]${reset} Setting ORACLE environment variables for current shell session"

    # ORACLE
    sudo ln -s /opt/oracle/instantclient_12_1/sdk/include $ORACLE_HOME/include
    export PATH=$PATH:/opt/oracle/instantclient_12_1
    export SQLPATH=/opt/oracle/instantclient_12_1
    export TNS_ADMIN=/opt/oracle/instantclient_12_1
    export LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1
    export ORACLE_HOME=/opt/oracle/instantclient_12_1
    # Set path to correct version of ruby for metasploit
    export PATH=/opt/metasploit/ruby/bin:$PATH
    # Call ~/.zshrc
    source ~/.zshrc
    export LD_LIBRARY_PATH
    sudo  touch /etc/profile.d/oracle.sh && sudo chmod o+r /etc/profile.d/oracle.sh
    grep -q -e 'export ORACLE_HOME=/opt/oracle/instantclient_12_1' /etc/profile.d/oracle.sh  || echo -e 'export ORACLE_HOME=/opt/oracle/instantclient_12_1' >>  /etc/profile.d/oracle.sh
    sudo touch /etc/ld.so.conf.d/oracle.conf && sudo chmod o+r /etc/ld.so.conf.d/oracle.conf
    grep -q -e '/opt/oracle/instantclient_12_1' /etc/ld.so.conf.d/oracle.conf || echo -e '/opt/oracle/instantclient_12_1' >>  /etc/ld.so.conf.d/oracle.conf
    sudo touch /etc/ld.so.conf.d/oracle-instantclient.conf && sudo chmod o+r /etc/ld.so.conf.d/oracle-instantclient.conf
    grep -q -e '/opt/oracle/instantclient_12_1' /etc/ld.so.conf.d/oracle-instantclient.conf || echo -e '/opt/oracle/instantclient_12_1' >>  /etc/ld.so.conf.d/oracle-instantclient.conf
    # Download ruby gem for ORACLE
    echo -e "${green}[*]${reset} Downloading ruby-oci8-2.1.8.zip"
    gem install 'ruby-oci8'


    # Install build dependencies with apt-get

    echo -e "${green}[*]${reset} Extracting ruby-oci8-2.1.8.zip ~ /opt/oracle"
    sudo apt-get install libgmp-dev ruby-dev

    # Set path to correct version of Ruby that MSF uses
    echo -e "${green}[*]${reset} Build ruby-oci8-2.1.8"
    cd /opt/oracle/ruby-oci8-ruby-oci8-2.1.8
    make clean && make && make install

    # Done
    echo -e "

    ${green}[*]Install finished${reset}"

fi
}
