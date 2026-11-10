#!/usr/bin/env bash

LOW_BATTERY_THRESHOLD=20
CRITICAL_BATTERY_THRESHOLD=10
BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
CHARGING_STATUS=$(cat /sys/class/power_supply/BAT0/status)

if [[ "$CHARGING_STATUS" != "Charging" && "$((BATTERY_LEVEL % 5))" -eq 0 ]]; then
    if [[ "$BATTERY_LEVEL" -le "$LOW_BATTERY_THRESHOLD" ]]; then
        if [[ "$BATTERY_LEVEL" -le "$CRITICAL_BATTERY_THRESHOLD" ]]; then
            hyprctl eval "low_power_mode(true)"
        fi
        notify-send -u critical "Low Battery" "Battery level is at $BATTERY_LEVEL%!"
    fi
fi
