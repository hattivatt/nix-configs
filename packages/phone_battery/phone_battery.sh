#!/bin/bash

device_id=297a38b5_bdab_45f1_8b94_114fd347c85e


if [[ $(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/${device_id}/battery org.kde.kdeconnect.device.battery.isCharging) == true ]]
then
	charge_icon="󱐋 "
else
	charge_icon=""
fi

if qdbus org.kde.kdeconnect /modules/kdeconnect/devices/${device_id}/battery org.kde.kdeconnect.device.battery.charge > /dev/null  2>&1; then
	echo " ${charge_icon}$(qdbus org.kde.kdeconnect /modules/kdeconnect/devices/${device_id}/battery org.kde.kdeconnect.device.battery.charge)%"
else
	echo ""
fi
