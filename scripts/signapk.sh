#!/bin/bash

if [[ -z "$1" ]]; then
	echo "Missing parameter, usage:";
	echo "signapk.sh APK_FILE KEYSTORE_PATH KEY_ALIAS";
	exit 1;
fi

if [[ -z "$2" ]]; then
	echo "Missing parameter, usage:";
	echo "signapk.sh APK_FILE KEYSTORE_PATH KEY_ALIAS";
	exit 1;
fi

if [[ -z "$3" ]]; then
	echo "Missing parameter, usage:";
	echo "signapk.sh APK_FILE KEYSTORE_PATH KEY_ALIAS";
	exit 1;
fi

APKFILE=$1
KEYSTORE_PATH=$2
KEY_ALIAS=$3
SLEEP=`which sleep`
ZIP=`which zip`
UNZIP=`which unzip`
ZIPALIGN=`which zipalign`
JARSIGNER=`which jarsigner`
APKUNZIPDIR=`echo "${APKFILE%%.*}"`
APKREZIPPED=`echo $APKFILE".rezipped"`
APKFINAL=`echo $APKFILE".final"`
CP=`which cp`
RM=`which rm`
MV=`which mv`
BANNERNAME=emptybanner.png



$UNZIP $APKFILE -d $APKUNZIPDIR

# Uncomment this to rewrite banner
# $CP $BANNERNAME $APKUNZIPDIR"/res/drawable/_corona_splash_screen.png"

cd "$APKUNZIPDIR"
$CP assets/*.ogg res/raw
$CP assets/*.wav res/raw
#$RM assets/*.caf
#$RM assets/*.ogg
#$RM assets/*.wav
$ZIP -r $APKREZIPPED . *
cd ..
$RM -rf $APKUNZIPDIR
$ZIP -d $APKREZIPPED META-INF/\*
$JARSIGNER -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $KEYSTORE_PATH $APKREZIPPED $KEY_ALIAS
$JARSIGNER -verify -verbose -certs $APKREZIPPED
$ZIPALIGN -v 4 $APKREZIPPED $APKFINAL
$RM $APKREZIPPED
$RM $APKFILE
$MV $APKFINAL $APKFILE

