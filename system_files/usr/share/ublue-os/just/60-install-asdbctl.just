spino-install-asdbctl:
    #!/usr/bin/env bash
    # you need cargo and systemd-devel packages installed to run this script succesfully
    # these do not ship with the image to reduce bloat
    # either layer them in temporarily with rpm-ostree
    # or use distrobox to install the packages and then run these commands manually
    cp -r /usr/share/ublue-os-spinosauros/asdbctl/ /tmp/
    cd /tmp/asdbctl/
    cargo install --path .
    
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
    
    rm -rf /tmp/asdbctl/
    
    sudo udevadm control --reload-rules
    sudo udevadm trigger
