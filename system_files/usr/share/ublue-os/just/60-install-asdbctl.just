install-asdbctl:
    #!/usr/bin/env bash
    cd /usr/share/ublue-os-spinosauros/asdbctl/
    cargo install --path .
    
    sudo udevadm control --reload-rules
    sudo udevadm trigger
