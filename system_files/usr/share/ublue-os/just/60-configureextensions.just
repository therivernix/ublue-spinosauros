enable-extensions:
    bash /usr/share/ublue-os-spinosauros/enableExtensions.sh

configure-extensions:
    dconf load /org/gnome/shell/extensions/ < /usr/share/ublue-os-spinosauros/extension-settings.dconf
    
install-extensions:
    bash /usr/share/ublue-os-spinosauros/installpipxandgnomeshellextensions.sh
    
