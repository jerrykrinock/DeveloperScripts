#!/bin/bash

ln="Bonehead of San José 134679"
sn="cIeanSzOJ9tTNY+7"

defaults write com.sheepsystems.Bookdog LicenseeName "$ln"
defaults write com.sheepsystems.Bookdog SerialNumber "$sn"

echo Bookdog has been licensed with:
echo Licensee Name: $ln
echo Serial Number: $sn
echo Thank you!
