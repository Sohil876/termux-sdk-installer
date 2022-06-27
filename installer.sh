#!/bin/bash
#
###  By @Sohil876
#

# Vars
arch=$(dpkg --print-architecture)
install_dir=${HOME}
sdk_version=33.0.1
with_cmdline=false
manifest="https://raw.githubusercontent.com/itsaky/androidide-build-tools/main/manifest.json"

# Color Codes
red='\e[0;31m'             # Red
green='\e[0;32m'        # Green
cyan='\e[0;36m'          # Cyan
white='\e[0;37m'        # White
nocol='\033[0m'         # Default

# Functions
banner() {
  echo -e "${green}------------------------------------------------"
  echo "          Termux Android SDK Installer"
  echo -e "               ${green}(${cyan}By ${green}-:- ${white}Sohil876${green})${nocol}"
  echo -e "${green}------------------------------------------------${nocol}"
}

help() {
  cat <<-_EOL_
$(echo -e "${green}Usage:${nocol}")
-h,  --help             Shows brief help
_EOL_
}

install_deps() {
  apt update
  pkg install curl wget termux-tools jq tar
}

# Main program
case ${@} in
  -h|--help)
    banner
    echo ""
    echo -e "${green}Note:-${nocol}"
    echo "This will NOT install ndk."
    echo ""
    help
    echo ""
    exit 0
  ;;
esac

# Error msg for no arguments specified
banner
echo ""
echo -e "${red}No arguments specified!${nocol}"
echo "See -h or --help for usage"
echo ""
exit 1

