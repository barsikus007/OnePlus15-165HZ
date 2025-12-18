#!/system/bin/sh
MODDIR=${0%/*}

log() {
  echo "[OnePlus15_165Hz] $1" >> /cache/magisk.log
}

log "Running post-fs-data.sh"

PATCH_DIR="$MODDIR/patched"
mkdir -p "$PATCH_DIR"

#? patch refresh_rate_config.xml
#<!-- format: mode_auto-mode_90-mode_60-mode_120
#      value: 0(unspecified), 1(90Hz), 2(60Hz), 3(120Hz)
#      rateId="3-0-2-3" the preferred refresh rate id per setting mode
#      setting mode: auto  ,90hz     ,60hz  ,120hz
#      refresh rate: 120hz ,default,  60hz  ,120hz
# -->
# 7-1-2-3 don't work at all
# 1-1-2-7 works with permanent 165Hz in auto mode
SRC="/my_product/etc/refresh_rate_config.xml"
DST="$PATCH_DIR/refresh_rate_config.xml"
if [ -f "$SRC" ]; then
  log "Patching $SRC"
  cp "$SRC" "$DST"
  sed -i '/<refresh_rate_config/,/}<\/refresh_rate_config>/ {
    /<config/ {
        s/defaultRateId="[^"]*"/defaultRateId="7-1-2-7"/g
        s/maxrefreshsettings="[^"]*"/maxrefreshsettings="7"/g
    }
    /<item/ s/rateId="[^"]*"/rateId="1-1-2-7"/g
  }' "$DST"
  mount --bind "$DST" "$SRC"
else
  log "Source file not found: $SRC"
fi

#? patch oplus_vrr_config.json
# yq -i -o=json '
#   .[5].game_list[].backlight_strategy[].fps = 165 |
#   .[15].level_list_for_120 = "165-60"
# ' oplus_vrr_config.json
# SRC="/my_product/etc/oplus_vrr_config.json"
# DST="$PATCH_DIR/oplus_vrr_config.json"
# if [ -f "$SRC" ]; then
#   log "Patching $SRC"
#   cp "$SRC" "$DST"
#   # Replace fps values
#   sed -i 's/"fps":[ 	]*[0-9]*/"fps": 165/g' "$DST"
#   # Replace level_list_for_120
#   sed -i 's/"level_list_for_120":[ 	]*"[^"]*"/"level_list_for_120": "165-60"/g' "$DST"
#   mount --bind "$DST" "$SRC"
# else
#   log "Source file not found: $SRC"
# fi

#? patch sys_dynamic_frame_config.xml
# SRC="/my_product/etc/sys_dynamic_frame_config.xml"
# DST="$PATCH_DIR/sys_dynamic_frame_config.xml"
# if [ -f "$SRC" ]; then
#   log "Patching $SRC"
#   cp "$SRC" "$DST"
#   sed -i \
#     -e 's/targetFramerate="[^"]*"/targetFramerate="165"/g' \
#     -e 's/enableEndLowRate="[^"]*"/enableEndLowRate="false"/g' \
#     -e 's/enableBreakAppRate60="[^"]*"/enableBreakAppRate60="false"/g' \
#     -e 's/enableBreakAppRate90="[^"]*"/enableBreakAppRate90="false"/g' \
#     "$DST"
#   mount --bind "$DST" "$SRC"
# else
#   log "Source file not found: $SRC"
# fi
