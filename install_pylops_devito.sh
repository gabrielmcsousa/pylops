#!/bin/bash
set -e
FOLDER_SET=false
CONDA_FOLDER="$HOME/miniconda3/bin/activate"

echo "*** Creating Pylops Conda Environment ***"
conda env create -f environment-dev.yml
echo "*** Activating Pylops Conda Environment ***"
source $CONDA_FOLDER pylops
echo "*** Installing Pylops ***"
pip install -e .

echo "*** Scaning for DEVITO source codes... ***"
# Scan HOME and subfolders for available devito source codes.
for FILE in $(grep -rl --include "*.py" --exclude-dir=".vscode-server" "name='devito'" $HOME 2>/dev/null)
do
    FOLDER=${FILE%/setup.py}
    echo "DEVITO source found in >> $FOLDER"
    read -p "Install devito from the above directory? (Y/N):" confirm
    case "$confirm" in
        y|Y )
            FOLDER_SET=true
            break
            ;;
        * ) continue;;
    esac
done

# Check if devito folder was set and continues installation.
if $FOLDER_SET ; then
    echo "Folder set! Continuing installation."
else
    echo "Devito folder not set. The script will now exit!"
    exit 1
fi

cd $FOLDER
echo "*** Installing Devito ***"
pip install -e .

echo "*** Fixing Incompatible Libraries ***"
pip install flake8==7.1.1 numba==0.60.0 numpy==1.26.4 numpydoc==1.7.0 scipy==1.14.1 sympy==1.13.3
