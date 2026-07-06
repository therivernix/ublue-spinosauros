enable-extensions:
    bash /etc/customscripts/enableExtensions.sh

configure-extensions:
    dconf load /org/gnome/shell/extensions/ < /etc/customscripts/extension-settings.dconf
    
install-extensions:
    bash /etc/customscripts/installpipxandgnomeshellextensions.sh
    
