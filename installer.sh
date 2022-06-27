#!/bin/bash
#
### Termux SDK Installer
#

# Vars
install_dir=${HOME}
manifest_url="https://raw.githubusercontent.com/itsaky/androidide-build-tools/main/manifest.json"
manifest="${PWD}/manifest.json"
# DO NOT CHANGE THESE!
CURRENT_SHELL="${SHELL##*/}"
CURRENT_DIR=${PWD}
arch=$(dpkg --print-architecture)

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
  echo ""
}

download_and_extract() {
  # Name shown in echo
  name=${1}
  # URL to download from
  url=${2}
  # Directory in which the downloaded archive will be extracted
  dir=${3}
  # Destination path for downloading the file
  dest=${4}

  cd ${dir}
  do_download=true
  if [[ -f ${dest} ]]; then
    name=$(basename ${dest})
    echo -e "${green}File ${name} already exists.${nocol}"
    echo "Do you want to skip the download process? ([${green}y${nocol}]es/[${red}N${nocol}]o): "
    read skip
    if [[ "${skip}" = "y" || "${skip}" = "yes" || "${skip}" = "Y" || "${skip}" = "Yes" ]]; then
      do_download=false
    fi
    echo ""
  fi

  if [[ "${do_download}" = "true" ]]; then
    echo -e "${green}Downloading ${name}...${nocol}"
    curl -L -o ${dest} ${url}
    echo -e "${green}${name} has been downloaded.${nocol}"
    echo ""
  fi

  if [[ ! -f ${dest} ]]; then
    echo -e "${red}The downloaded file ${name} does not exist! Aborting...${nocol}"
    exit 1
  fi
  # Extract the downloaded archive
  echo -e "${green}Extracting downloaded archive...${nocol}"
  tar xvJf ${dest}
  echo -e "${green}Extracted successfully${nocol}"
  echo ""
  # Delete the downloaded file
  rm -vf ${dest}
  # cd into the previous working directory
  cd ${CURRENT_DIR}
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
-i, --install           Start installation, installs jdk and android sdk with cmdline and build tools
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
  echo -e "${green}SDK from:${nocol} https://github.com/itsaky"
}

install() {
  echo ""
  gen_data
  echo -e "${green}Installing dependencies...${nocol}"
  apt update
  pkg install curl wget termux-tools jq tar -y
  echo -e "${red}!${nocol}${green}This will download ~400MB size files and will take ~600MB space on disk.${nocol}"
  echo -e "Continue? ([${green}y${nocol}]es/[${red}N${nocol}]o): "
  read proceed
  if ! ([[ "$proceed" = "y" || "$proceed" = "yes" || "$proceed" = "Y" || "$proceed" = "Yes" ]]); then
    echo -e "${red}Aborted!${nocol}"
    exit 1
  fi
  echo -e "${green}Installing jdk...${nocol}"
  pkg install openjdk-17 -y
  echo -e "${green}Downloading sdk files...${nocol}"
  # Download and extract the Android SDK
  download_and_extract "Android SDK" $sdk_url $install_dir "$install_dir/android-sdk.tar.xz"
  # Download and extract cmdline tools
  download_and_extract "Command line tools" $cmdline_url "$install_dir/android-sdk" "$install_dir/cmdline_tools.tar.xz"
  # Setting env vars
  echo -e "${green}Setting up env vars...${nocol}"
  if [[ "${CURRENT_SHELL}" == "bash" ]]; then
    shell_profile="${HOME}/.basrc"
  elif [[ "${CURRENT_SHELL}" == "zsh" ]]; then
    shell_profile="${HOME}/.zshrc"
  else
    unsupported_shell_used=true
    echo "${red}Unsupported shell!${nocol}"
    echo "You will need to manually export env vars JAVA_HOME and ANDROID_SDK_ROOT on every session to use sdk:"
    echo "export JAVA_HOME=${PREFIX}/opt/openjdk-17"
    echo "export ANDROID_SDK_ROOT=${install_dir}/android-sdk"
    exit 0
  fi
  if [[ -z "${unsupported_shell_used}" ]]; then
    if [[ -z "${JAVA_HOME}" ]]; then
      echo "JAVA_HOME=${PREFIX}/opt/openjdk" >> ${shell_profile}
    else
      echo "${JAVA_HOME}"
    fi
    if [[ -z "${ANDROID_SDK_ROOT}" ]]; then
      echo "ANDROID_SDK_ROOT=${install_dir}/android-sdk" >> ${shell_profile}
    else
      echo "${ANDROID_SDK_ROOT}"
    fi
  fi
  apt clean
}

# Main program
case ${@} in
  -h|--help)
    banner
    echo -e "${green}Note:-${nocol}"
    echo "This will NOT install ndk."
    echo ""
    help
    echo ""
    exit 0
  ;;
  --info)
    banner
    info
    echo ""
    exit 0
  ;;
  -i|--install)
    banner
    if [[ ! -d ${install_dir} ]]; then
      echo -e "${red}Your install directory doesn't exists!"
      echo "If you didnt change in script then that means your home directory doesn't exist, in that case there's something wrong with your termux installation, please reinstall termux!"
      echo "Else if you've changed install directory var to something else make sure it exists!"
      exit 1
    fi
    install
    echo -e "${green}Installed Android SDK and OpenJDK sucessfully!"
    echo -e "${green}Please restart termux${nocol}${red}!${nocol}"
    echo ""
    exit 0
  ;;
esac

# Error msg for no arguments specified
banner
echo -e "${red}No arguments specified!${nocol}"
echo "See -h or --help for usage"
echo ""
exit 1

