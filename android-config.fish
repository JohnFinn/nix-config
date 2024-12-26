#!/usr/bin/env fish
# adb install (bkt --ttl 1h -- curl https://f-droid.org/F-Droid.apk | psub --suffix .apk)

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
        break
    end
end

ensure_installed com.whatsapp
ensure_installed org.telegram.messenger
ensure_installed com.nutomic.syncthingandroid
