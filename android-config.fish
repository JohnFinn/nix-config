#!/usr/bin/env fish
adb shell settings put system haptic_feedback_enabled 0

function fetch_from_fdroid_repo
    bkt --ttl 1h -- curl https://f-droid.org/repo/(bkt --ttl 1h -- curl https://f-droid.org/repo/index.xml | xq -r ".fdroid.application[] | select(.id == \"$argv\") .package[0].apkname")
end
adb shell settings put global verifier_verify_adb_installs 0

adb install (bkt --ttl 1h -- curl https://distractionfreeapps.com/build/dfinsta_1_4_1.apk | psub --suffix .apk)
adb install (fetch_from_fdroid_repo org.fdroid.fdroid | psub --suffix .apk)
adb install (fetch_from_fdroid_repo com.nutomic.syncthingandroid | psub --suffix .apk)
adb install (fetch_from_fdroid_repo com.ichi2.anki | psub --suffix .apk)
adb install (fetch_from_fdroid_repo com.termux | psub --suffix .apk)
adb install (bkt --ttl 1h -- curl --location https://github.com/topjohnwu/Magisk/releases/download/v28.1/Magisk-v28.1.apk | psub --suffix .apk)

function is_installed
    adb shell cmd package list packages | rg "package:$argv\$"
end

function screen_locked
    adb shell dumpsys window | rg mDreamingLockscreen=true
end

function ensure_installed
    if is_installed "$argv"
        return
    end
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
ensure_installed mentz.com.vrr_cibo_app
