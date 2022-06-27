#!/bin/bash
#
###  By @Sohil876
#

# Vars
CURRENT_SHELL="${SHELL##*/}"
arch=$(dpkg --print-architecture)
install_dir=${HOME}
manifest_url="https://raw.githubusercontent.com/itsaky/androidide-build-tools/main/manifest.json"
manifest="${PWD}/manifest.json"

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

gen_data() {
  if ! command -v curl &> /dev/null; then
    echo -e "${red}curl is not installed!${nocol}"
    echo "Install it with pkg install curl"
    exit 1
  fi
  curl --silent -L -o ${manifest} ${manifest_url}
  tmp=$(cat ${manifest} | jq -n "[inputs[] | keys[]]" | jq -r ".[0]")
  sdk_m_version="${tmp:1}"
  sdk_version="${sdk_m_version//_/.}"
  sdk_url_string=".android_sdk._${sdk_m_version}.${arch}.sdk"
  sdk_url=$(cat ${manifest} | jq -r ${sdk_url_string})
  cmdline_url=$(cat ${manifest} | jq -r ".android_sdk.cmdline_tools")
  rm ${manifest}
}

help() {
  cat <<-_EOL_
$(echo -e "${green}Usage:${nocol}")
-h,  --help             Shows brief help
--info                  Show info about sdk, arch, etc
_EOL_
}

info() {
  gen_data
  echo -e "${green}Active Shell:${nocol} ${CURRENT_SHELL}"
  echo -e "${green}Arch:${nocol} ${arch}"
  echo -e "${green}JDK:${nocol} OpenJDK 17"
  echo -e "${green}SDK version:${nocol} v${sdk_version}"
  echo -e "${green}SDK url:${nocol} ${sdk_url}"
  echo -e "${green}SDK cmdline tools url:${nocol} ${cmdline_url}"
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
  --info)
    banner
    echo ""
    info
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

