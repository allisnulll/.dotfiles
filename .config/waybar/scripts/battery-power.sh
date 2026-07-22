#!/usr/bin/env bash

BAT_PATH=$(upower -e 2>/dev/null | grep BAT | head -n 1)

if [ -n "$BAT_PATH" ]; then
    INFO=$(upower -i "$BAT_PATH")
    STATE=$(echo "$INFO" | awk '/state:/ {print $2}')
    LEVEL=$(echo "$INFO" | awk '/percentage:/ {print $2}' | tr -d '%')
    ENERGY=$(echo "$INFO" | awk '/^\s*energy:/ {print $2}')
    ENERGY_FULL=$(echo "$INFO" | awk '/^\s*energy-full:/ {print $2}')
    RATE=$(echo "$INFO" | awk '/energy-rate:/ {print $2}')

    ICONS=("󰂎" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")

    time_to_hm() {
        awk "BEGIN{
            h=int($1);
            m=int(($1-h)*60);
            printf \"%d h %d min\", h, m
        }"
    }

    case "$STATE" in
        fully-charged)
            CLASS="charging"
            TEXT=" ${LEVEL}%"
            TOOLTIP="Full"
            ;;
        charging)
            CLASS="charging"
            TEXT=" ${LEVEL}%"
            if [ -n "$RATE" ] && [ -n "$ENERGY_FULL" ] && [ -n "$ENERGY" ] \
               && awk "BEGIN{exit !($RATE>0)}"; then
                HOURS=$(awk "BEGIN{printf \"%.4f\", ($ENERGY_FULL-$ENERGY)/$RATE}")
                TOOLTIP=$(time_to_hm "$HOURS")
            else
                TOOLTIP="Full"
            fi
            ;;
        discharging|pending-discharge)
            if [ "$LEVEL" -le 10 ]; then
                CLASS="critical"
            elif [ "$LEVEL" -le 20 ]; then
                CLASS="warning"
            else
                CLASS="discharging"
            fi

            IDX=$((LEVEL / 10))
            [ "$IDX" -gt 9 ] && IDX=9
            TEXT="${ICONS[$IDX]} ${LEVEL}%"
            if [ -n "$RATE" ] && [ -n "$ENERGY" ] \
               && awk "BEGIN{exit !($RATE>0)}"; then
                HOURS=$(awk "BEGIN{printf \"%.4f\", $ENERGY/$RATE}")
                TOOLTIP=$(time_to_hm "$HOURS")
            elif [ "$LEVEL" -le 0 ]; then
                TOOLTIP="Empty"
            else
                TOOLTIP="Discharging"
            fi
            ;;
        *)
            CLASS="discharging"
            TEXT="${ICONS[0]} ${LEVEL}%"
            TOOLTIP="Discharging"
            ;;
    esac

    printf '{"text":"%s","tooltip":"%s","class":"%s"}' "$TEXT" "$TOOLTIP" "$CLASS"
else
    PJ="/tmp/powerjoular-service.csv"

    if [ -f "$PJ" ] && [ -s "$PJ" ]; then
        WATTS=$(tail -1 "$PJ" | awk -F',' '{printf "%.0f", $3}')

        PREV_FILE="/tmp/waybar-powerjoular-prev"
        ARROW="→"
        if [ -f "$PREV_FILE" ]; then
            PREV=$(cat "$PREV_FILE")
            if [ -n "$PREV" ]; then
                DIFF=$((WATTS - PREV))
                if [ "$DIFF" -gt 0 ]; then
                    ARROW="<span foreground='#f38ba8'>↗</span>"
                elif [ "$DIFF" -lt 0 ]; then
                    ARROW="<span foreground='#a6e3a1'>↘</span>"
                fi
            fi
        fi
        echo "$WATTS" > "$PREV_FILE"

        printf '{"text":" %sW %s ","tooltip":"Power Consumption: %sW","class":"power","markup":true}' "$WATTS" "$ARROW" "$WATTS"
    else
        printf '{"text":" ---W → ","tooltip":"Enable powerjoular: systemctl --user enable --now powerjoular","class":"power"}'
    fi
fi
