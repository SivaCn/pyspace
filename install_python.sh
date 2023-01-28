#!/bin/sh


#
# Ansi color code variables
COL_RED="\e[0;91m"
COL_BLUE="\e[0;34m"
COL_GREEN="\e[0;92m"
COL_WHITE="\e[0;97m"
COL_RESET="\e[0m"

BOLD="\e[1m"

FRESH_INSTALL=false

#
# Console arguments
while getopts f option
    do
        case "${option}"
        in
            f) FRESH_INSTALL='force';;
        esac
    done



PYTHON_EXE=bin/python3.7
PYTHON_NAME=Python
PYTHON_VERSION=3.7.16
PYTHON_DIR=$PYTHON_NAME-${PYTHON_VERSION}
PYTHON_TAR=${PYTHON_DIR}.tar.xz

HOME_DIR=`pwd`
DEP_DIR=${HOME_DIR}/dependencies

printf "\n\n${COL_BLUE}Creating directories... ${COL_RESET}"
if [ -d "${DEP_DIR}" ]; then
    printf "${COL_RED}${BOLD}Directory Exists${COL_RESET}\n"
else
    mkdir -p ${DEP_DIR}
    printf "${COL_GREEN}${BOLD}Done${COL_RESET}\n"
fi

printf "\n${COL_BLUE}Cleaning up the dependencies directory... ${COL_RESET}"
rm -rf ${DEP_DIR}/*
printf "${COL_GREEN}${BOLD}Done${COL_RESET}\n"


cd_home() {
    cd ${HOME_DIR}
}


rm_dir_if_exists() {
    printf "\n${COL_BLUE}Directory Clean up ($1) ... ${COL_RESET}"
    if [ -d $1 ]; then
        printf "${COL_GREEN}${BOLD}Done${COL_RESET}\n"
        rm -rf $1
    else
        printf "${COL_RED}${BOLD}Skipped, dir not found${COL_RESET}\n"
    fi
}


install_python() {

    if [ "$FRESH_INSTALL" = "force" ]; then

        printf "\n${COL_RED}${BOLD}Cleaning up the existing environment for the clean (forced) install ${COL_RESET}\n"

        for directory in bin lib share cache include artifacts var local;
            do
                rm_dir_if_exists ${HOME_DIR}/$directory;
            done
    fi

    rm_dir_if_exists ${DEP_DIR}/${PYTHON_DIR}

    printf "\n${COL_BLUE}Trying to install Python ... ${COL_RESET}"

    if [ -f "${HOME_DIR}/${PYTHON_EXE}" ]; then
        printf "${COL_GREEN}${BOLD}Python is already installed. ${COL_RESET}\n"

    else
        printf "${COL_RED}${BOLD}Installing Python freshly. ${COL_RESET}\n"

        wget https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_TAR -O dependencies/$PYTHON_TAR

        tar -xJf ${DEP_DIR}/${PYTHON_TAR} --directory=${DEP_DIR}

        cd ${DEP_DIR}/${PYTHON_DIR}

        printf "${COL_BLUE}${BOLD} Running with out Optimizations ... ${COL_RESET}"
        ./configure --prefix=`pwd`/../../ --with-ensurepip=install

        make
        make install

        printf "\n${COL_RED}${BOLD}Successfully completed the python installation. ${COL_RESET}\n\n"
    fi

    cd_home

    rm_dir_if_exists ${DEP_DIR}/${PYTHON_DIR}

    #
    # Upgrading pip version to latest one
    printf "\n${COL_BLUE}Upgrading pip to latest version... ${RESET}"
    ${HOME_DIR}/${PYTHON_EXE} -m pip install --upgrade pip
    printf "${COL_GREEN}${BOLD}Done${COL_RESET}\n"

    #
    # Upgrading setuptools
    printf "\n${COL_BLUE}Upgrading setuptools to the latest version ... ${RESET}"
    ${HOME_DIR}/${PYTHON_EXE} -m pip install --upgrade setuptools
    printf "${COL_GREEN}${BOLD}Done${COL_RESET}\n"
}


install_python
