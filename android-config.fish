#!/usr/bin/env fish
adb shell settings put system haptic_feedback_enabled 0
adb install-multiple (bkt --ttl 1h -- curl https://f-droid.org/F-Droid.apk | psub --suffix .apk) (bkt --ttl 1h -- curl https://distractionfreeapps.com/build/dfinsta_1_4_1.apk | psub --suffix .apk)

function is_installed
    adb shell cmd package list packages | rg "package:$argv\$"
end

function screen_locked
    adb shell dumpsys window | rg mDreamingLockscreen=true
end

function ensure_installed
    while screen_locked
        echo 'unlock screen'
        sleep 1
    end
    is_installed "$argv" || adb shell am start -a android.intent.action.VIEW -d "market://details?id=$argv"

    # wait for user clicks
    while not is_installed "$argv"
        sleep 1
    end
end

ensure_installed com.whatsapp
ensure_installed org.telegram.messenger
ensure_installed com.nutomic.syncthingandroid
ensure_installed com.ichi2.anki
ensure_installed mentz.com.vrr_cibo_app
