#!/bin/bash

#   This is a simple scritp to automatically install both Pylops and Devito on a conda environment.
#   The default directory for the conda activate script is at "$HOME/miniconda3/bin/activate", if you'd like to change it,
#       set a different one as the first positional argument for this script.
#   The script will scan your home environment for the devito folder containing the source code and ask you whether that
#       is the right one to install or not. If you'd like to change this as well, pass it as the second positional argument to the script.
#   Both folders can also be directly altered on the lines below if you want to change their default locations.

set -e
FOLDER_SET=false
CONDA_FOLDER=${1:-"$HOME/miniconda3/bin/activate"}
DEVITO_FOLDER=${2:-""}

if test -f $CONDA_FOLDER; then
    echo "*** Conda activate script set ***"
else
    echo "*** Conda activate script not found! Aborting installation!! ***"
    exit 1
fi

# Scan HOME and subfolders for available devito source codes.
if [[ -n "$DEVITO_FOLDER" ]]; then
    echo "*** Using devito source code found in $DEVITO_FOLDER ***"
else
    echo "*** Scaning for DEVITO source codes... ***"
    for FILE in $(grep -rl --include "setup.py" --exclude-dir=".vscode-server" "name='devito'" $HOME 2>/dev/null)
    do
        DEVITO_FOLDER=${FILE%/setup.py}
        echo "DEVITO source found in >> $DEVITO_FOLDER"
        read -p "Install devito from the above directory? (Y/N):" confirm
        case "$confirm" in
            y|Y )
                FOLDER_SET=true
                break
                ;;
            * ) continue;;
        esac
    done
fi

# Check if devito folder was set and continues installation.
if $FOLDER_SET ; then
    echo "*** Devito folder set! Continuing installation... ***"
else
    echo "*** Devito folder not set. Aborting installation!! ***"
    exit 1
fi

echo "*** Creating Pylops Conda Environment ***"
conda env create -f environment-dev.yml

echo "*** Activating Pylops Conda Environment ***"
source $CONDA_FOLDER pylops

echo "*** Installing Pylops ***"
pip install -e .


cd $DEVITO_FOLDER
echo "*** Installing Devito ***"
pip install -e .

echo "*** Fixing Incompatible Libraries ***"
pip install flake8==7.1.1 numba==0.60.0 numpy==1.26.4 numpydoc==1.7.0 scipy==1.14.1 sympy==1.13.3
