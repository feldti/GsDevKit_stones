##!/bin/bash
#
# Dieses Skript lädt den aktuellen Softwarecode der Anwendung in das Datenbanksystem
# Dieses Skript initialisiert NICHT die globale Datenstruktur, unter der alles abgespeichert wird
# Also: Wenn mit diesem Skript in einen Stone zum ersten Male die Anwendung geladen wurde, dann
# sollte man auch das Skript pas_initialize_application.sh ausführen - erst diese Anwendung 
# legt die 
#

#
# Aus welchen Paketen besteht die Anwendung
#
PAS_APP_MODEL_PACKAGE="SurveyManager"
PAS_APP_MODEL_EXTENSION_PACKAGE="SurveyManagerExtension"

if [ ! -f ./credentials.sh ]; then
  echo 'Missing credentials.sh - copy demo_credentials.sh and make the needed changes to it'
  exit 4
fi

#
# load all the needed information
#
source ./credentials.sh
# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $PAS_STONE_NAME $PAS_STONE_REGISTRY $STONES_DATA_HOME)

# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo ""
else
    echo "The script failed with return code $?."
    exit 3
fi
# Check if stone_dir was found
if [[ -z "$stone_dir" ]]; then
    echo "Error: 'stone_dir' not found in $ston_file_path"
    exit 2
fi
source $stone_dir/customenv
if [ -s $GEMSTONE/seaside/etc/gemstone.secret ]; then
    . $GEMSTONE/seaside/etc/gemstone.secret
else
    echo 'Missing password file $GEMSTONE/seaside/etc/gemstone.secret'
    exit 1
fi

cat << EOF | $GEMSTONE/bin/topaz -lq -T 4000000 -u pas_load_application
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME
iferror where
login
run
| aSymbol names userProfile symbolDictionary | 
aSymbol := #'${PAS_APP_DATA_CLASS}'.
userProfile := System myUserProfile.
names := userProfile symbolList names.
(names includes: aSymbol) ifFalse: [
	symbolDictionary := SymbolDictionary new name: aSymbol; yourself.
	userProfile insertDictionary: symbolDictionary at: names size + 1.
].
(symbolDictionary := System myUserProfile objectNamed: '${PAS_APP_DATA_CLASS}') isNil ifFalse:[
	(symbolDictionary includesKey: #'DataRootInstance') ifFalse: [
		| projectClass | 
		(projectClass := System myUserProfile objectNamed: '${PAS_APP_PROJECT_CLASS}') isNil ifFalse:[
			symbolDictionary at: #'DataRootInstance' put: projectClass new initialize
		].
	].
].
%
commit
doit
Gofer new
        url: '$PAS_APP_PACKAGES' ;
        package: '$PAS_APP_MODEL_PACKAGE' ;
        load.
%
doit
Gofer new
        url: '$PAS_APP_PACKAGES' ;
        package: '$PAS_APP_MODEL_EXTENSION_PACKAGE' ;
        load.
%
commit
run
| aSymbol names userProfile symbolDictionary | 
aSymbol := #'${PAS_APP_DATA_CLASS}'.
userProfile := System myUserProfile.  
names := userProfile symbolList names.
(names includes: aSymbol) ifFalse: [  
        symbolDictionary := SymbolDictionary new name: aSymbol; yourself. 
        userProfile insertDictionary: symbolDictionary at: names size + 1.
].
(symbolDictionary := System myUserProfile objectNamed: '${PAS_APP_DATA_CLASS}') isNil ifFalse:[
        (symbolDictionary includesKey: #'DataRootInstance') ifFalse: [
                | projectClass | 
                (projectClass := System myUserProfile objectNamed: '${PAS_APP_PROJECT_CLASS}') isNil ifFalse:[
                        symbolDictionary at: #'DataRootInstance' put: projectClass new initialize
                ].
        ].
].
${PAS_APP_ERROR_CLASS} initializeLocalizedDefinitions.
%
commit
EOF
pas_refresh_api.sh credentials 
exit 0
