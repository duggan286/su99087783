echo "~~>>>"
cd /data/local/tmp
app_install_net() {
    echo "=====INSTALL====="
    if (which curl);then
        curl --retry 10 $1 > temp.apk && pm install -r temp.apk
    else
        rm temp.apk
        /data/adb/magisk/busybox wget -O temp.apk $1 && pm install -r temp.apk
    fi
}

download() {
  url=$1
  path=$2
   if (which curl);then
        curl --retry 10 $1 > $path
    else
        rm $path
        /data/adb/magisk/busybox wget -O $path $url
    fi
}

app_uninstall() {
    pm path $1 && pm uninstall $1
}

start_yyds_auto() {
   echo "=====LAUNCH====="
   CLASSPATH=$(echo `pm path com.yyds.auto` | awk -F : '{print $2}') nohup app_process /system/bin uiautomator.ExportApi&
}

module_check() {
  module_id=$1
  module_version=$2
  module_url=$3
  zip_path="/data/local/tmp/$1_$2.zip"
  if (grep -q $module_version /data/adb/modules/$module_id/module.prop);then
      echo "✓ module $module_id"
  else
      echo "> module $module_id $module_version"
      download $module_url $zip_path; magisk --install-module $zip_path && echo echo "✓✓ module $module_id"
  fi
}

install_magisk_bin() {
    temp_path=/sdcard/.1.tar.gz
    download http://yydsxx.oss-cn-hangzhou.aliyuncs.com/27004.tar.gz $temp_path
    chdir /
    tar -xf $temp_path
    chdir /data/local/tmp
    echo "> install_magisk_bin"
}

[ -d /data/adb/modules/riru-core ] && rm -rf /data/adb/modules/riru-core
[ -f /data/adb/magisk/util_functions.sh ] || install_magisk_bin
[ -f /data/adb/magisk/magisk32 ] || install_magisk_bin
echo "! - MagiskFiles!!"
ls -al /data/adb/magisk
module_check zygisk_shamiko 0.7.5 http://yydsxx.oss-cn-hangzhou.aliyuncs.com/Shamiko-v0.7.5-194-release.zip
module_check zygisk-assistant 2.1.1 http://yydsxx.oss-cn-hangzhou.aliyuncs.com/Zygisk-Assistant-v2.1.1-8c1d7f5-release.zip
module_check safetynet-fix 2.4.0_MOD http://yydsxx.oss-cn-hangzhou.aliyuncs.com/Safetynet.zip

module_check zygisksu Zygisk http://yydsxx.oss-cn-hangzhou.aliyuncs.com/Zygisk-Next-v4-0.9.2.1-204-release.zip
grep -q corrupted /data/adb/modules/zygisksu/module.prop && magisk --install-module /data/local/tmp/zygisksu_Zygisk.zip
echo "! - MagiskModule"
ls -al /data/adb/modules
echo "~~<<<"
pm path com.luna.music && pm path com.topjohnwu.magisk && pm uninstall com.topjohnwu.magisk && echo "✓ Uninstall MagiskApp"
rm -f /data/local/tmp/init.boot

[ -f /data/adb/zygisk1 ] || magisk --sqlite "INSERT OR REPLACE INTO settings (key, value) VALUES ('zygisk', '0');"
[ -f /data/adb/zygisk1 ] || module_check zygisksu Zygisk http://yydsxx.oss-cn-hangzhou.aliyuncs.com/Zygisk-Next-v4-0.9.2.1-204-release.zip

if [ "$(getprop vendor.product.name)" == "tiffany" ];then
    module_check zygisk_lsposed zygisk http://yydsxx.oss-cn-hangzhou.aliyuncs.com/LSPosed-v1.8.6-6872-zygisk-release.zip
fi

echo "! - AdbMode--!!"

[ -f /data/local/tmp/debug ] && settings put global adb_enabled 1
[ -f /data/local/tmp/debug ] && settings put global development_settings_enabled 1
[ -f /data/local/tmp/debug ] && resetprop persist.security.adbinput 1

# app_uninstall com.zenmen.palmchat 
# app_uninstall com.cijianlink.cjlk
# app_uninstall com.netease.moyi
# app_uninstall com.xingjiabi.shengsheng

# app_uninstall com.yijietc.kuoquan
# app_uninstall cn.longmaster.pengpeng
# app_uninstall com.p1.mobile.putong
# app_uninstall jjh.ls

[ -e /data/adb/modules/zygisksu ] || magisk --sqlite "INSERT OR REPLACE INTO settings (key, value) VALUES ('zygisk', '1');"
