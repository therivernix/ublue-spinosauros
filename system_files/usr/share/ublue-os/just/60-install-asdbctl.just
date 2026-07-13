install-asdbctl:
    #!/usr/bin/env bash
    cp -r /usr/share/ublue-os-spinosauros/asdbctl/ /tmp/
    cd /tmp/asdbctl/
    cargo install --path .
    
    sudo udevadm control --reload-rules
    sudo udevadm trigger
