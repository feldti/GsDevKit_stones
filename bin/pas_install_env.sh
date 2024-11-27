#! /usr/bin/env bash
#
# Dieses Skript legt die gesamte Struktur für PAS an. Auch wenn es hier versioniert ist, sollte das
# Skript auch extern verfügbar gemacht werden, damit man die Installation überhaupt starten kann.
PAS_HOME_NAME="pas"
DEFAULT_REGISTRY_NAME="work"
PAS_TEMPLATES_DIRECTORY_NAME="pas-templates"
PAS_TEMPLATES_DOWNLOAD_FILENAME="all.zip"
PAS_TEMPLATES_DOWNLOAD_LINK="https://feldtmann.ddns.net/pas-template-databases/$PAS_TEMPLATES_DOWNLOAD_FILENAME"

if [ -d $PAS_HOME_NAME ]; then
	echo "Aborting: Local PAS main directory already available"
	exit 1
fi

# create the master directory
mkdir $PAS_HOME_NAME
cd $PAS_HOME_NAME
PAS_HOME_PATH=`pwd`
mkdir "$PAS_TEMPLATES_DIRECTORY_NAME"
cd  "$PAS_TEMPLATES_DIRECTORY_NAME"
wget $PAS_TEMPLATES_DOWNLOAD_LINK
unzip $PAS_TEMPLATES_DOWNLOAD_FILENAME
rm $PAS_TEMPLATES_DOWNLOAD_FILENAME
cd ..
mkdir "products"
mkdir "products/$DEFAULT_REGISTRY_NAME"
mkdir "stones"
mkdir "stones/$DEFAULT_REGISTRY_NAME"
mkdir "stones_data_home"
# all external git stuff is hidden behind git
mkdir "git"
cd git
git clone --branch v2.1 "https://github.com/feldti/GsDevKit_stones.git"
./GsDevKit_stones/bin/install.sh
echo "Add the following sequence to your local .bashrc"


export PAS_HOME_PATH=$PAS_HOME_PATH
export PATH=$PAS_HOME_PATH/git/superDoit/bin:\$PAS_HOME_PATH/git/GsDevKit_stones/bin:$PATH
export STONES_DATA_HOME=$PAS_HOME_PATH/stones_data_home
export PAS_DEFAULT_REGISTRY=$DEFAULT_REGISTRY_NAME
#
# Now we add an initial registry
#
createRegistry.solo $DEFAULT_REGISTRY_NAME --ensure
registerStonesDirectory.solo --registry=$DEFAULT_REGISTRY_NAME --stonesDirectory=$PAS_HOME_PATH/stones/$DEFAULT_REGISTRY_NAME
registerProductDirectory.solo --registry=$DEFAULT_REGISTRY_NAME --productDirectory=$PAS_HOME_PATH/products/$DEFAULT_REGISTRY_NAME
#
# Information for furthr work to be doneby the user
#
echo
echo export PAS_HOME_PATH=$PAS_HOME_PATH
echo export PAS_DEFAULT_REGISTRY=$DEFAULT_REGISTRY_NAME
echo export PATH=\$PAS_HOME_PATH/git/superDoit/bin:\$PAS_HOME_PATH/git/GsDevKit_stones/bin:\$PATH
echo export STONES_DATA_HOME=\$PAS_HOME_PATH/stones_data_home
