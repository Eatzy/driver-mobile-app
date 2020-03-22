#!/bin/bash

CP=`which cp`
RM=`which rm`
MKDIR=`which mkdir`
ZIP=`which zip`
BANNERNAME=emptybanner.png

# Uncomment this to rewrite banner
# $CP $BANNERNAME $1.app/_CoronaSplashScreen.png
# must be resigned
# http://stackoverflow.com/questions/5160863/how-to-re-sign-the-ipa-file

$MKDIR Payload
$CP -R $1.app Payload/
$ZIP -r $1.ipa Payload
$RM -fR Payload
