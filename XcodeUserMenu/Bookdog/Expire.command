#!/bin/bash

ln="Demo_82BQHYi/vbp8j+/xNqDkQ57nV68=03435106"
sn="m3prdVH2O112TCnX"

defaults write com.sheepsystems.Bookdog LicenseeName "$ln"
defaults write com.sheepsystems.Bookdog SerialNumber "$sn"

echo Bookdog has been expired with:
echo Licensee Name: $ln
echo Serial Number: $sn
echo Thank you!
