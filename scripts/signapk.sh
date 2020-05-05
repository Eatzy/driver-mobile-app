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

if [[ ! -f "$1" ]]; then
	echo "No APK file at ${1}";
	exit 1;
fi

if [[ ! -f "$2" ]]; then
	echo "No keystore file at ${2}";
	exit 1;
fi

SLEEP=`which sleep`
ZIP=`which zip`
UNZIP=`which unzip`
ZIPALIGN=`which zipalign`
JARSIGNER=`which jarsigner`
CP=`which cp`
RM=`which rm`
MV=`which mv`
BANNERNAME=emptybanner.png

if [[ -z "$ZIP" ]]; then
	echo "zip command not found";
	exit 1;
fi

if [[ -z "$UNZIP" ]]; then
	echo "unzip command not found";
	exit 1;
fi

if [[ -z "$ZIPALIGN" ]]; then
	echo "zipalign command not found";
	exit 1;
fi

if [[ -z "$JARSIGNER" ]]; then
	echo "jarsigner command not found";
	exit 1;
fi

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

APKFILE=`realpath "${1}"`
KEYSTORE_PATH=`realpath "${2}"`
KEY_ALIAS=$3
APKUNZIPDIR=`echo "${APKFILE%%.*}"`
APKREZIPPED=`echo $APKFILE".rezipped"`
APKORIGINAL=`echo $APKFILE".original"`
APKFINAL=`echo $APKFILE".final"`

echo "APKFILE: ${APKFILE}"
echo "KEYSTORE_PATH: ${KEYSTORE_PATH}"
echo "KEY_ALIAS: ${KEY_ALIAS}"
echo "APKUNZIPDIR: ${APKUNZIPDIR}"
echo "APKREZIPPED: ${APKREZIPPED}"
echo "APKORIGINAL: ${APKORIGINAL}"
echo "APKFINAL: ${APKFINAL}"

$CP $APKFILE $APKORIGINAL
$UNZIP $APKFILE -d $APKUNZIPDIR

cd $APKUNZIPDIR
$CP assets/*.ogg res/raw
$CP assets/*.wav res/raw
#$RM assets/*.caf
#$RM assets/*.ogg
#$RM assets/*.wav
$ZIP -r $APKREZIPPED . *
cd ..
$ZIP -d $APKREZIPPED META-INF/\*
$JARSIGNER -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $KEYSTORE_PATH $APKREZIPPED $KEY_ALIAS
$JARSIGNER -verify -verbose -certs $APKREZIPPED
$ZIPALIGN -v 4 $APKREZIPPED $APKFINAL

$RM -rf $APKUNZIPDIR
$RM -f $APKREZIPPED
$RM -f $APKFILE
$MV $APKFINAL $APKFILE

