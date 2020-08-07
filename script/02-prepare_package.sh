#!/bin/bash
clear

#使用19.07的feed源
rm -f ./feeds.conf.default
wget https://raw.githubusercontent.com/openwrt/openwrt/openwrt-19.07/feeds.conf.default
wget -P include/ https://raw.githubusercontent.com/openwrt/openwrt/openwrt-19.07/include/scons.mk
patch -p1 < ../patches/main/0001-tools-add-upx-ucl-support.patch

#去除snapshot标签
sed -i 's,SNAPSHOT,,g' include/version.mk
sed -i 's,snapshots,,g' package/base-files/image-config.in

#使用O3级别的优化
sed -i 's/Os/O3/g' include/target.mk
sed -i 's/O2/Ofast/g' ./rules.mk

#更新feed
./scripts/feeds update -a && ./scripts/feeds install -a

#irqbalance
sed -i 's/0/1/g' feeds/packages/utils/irqbalance/files/irqbalance.config

##必要的patch
#patch i2c0
cp -f ../patches/main/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch ./target/linux/rockchip/patches-5.4/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch

#patch rk-crypto
patch -p1 < ../patches/main/kernel_crypto-add-rk3328-crypto-support.patch

#patch jsonc
patch -p1 < ../patches/package/use_json_object_new_int64.patch

#patch dnsmasq
patch -p1 < ../patches/package/dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ../patches/package/luci-add-filter-aaaa-option.patch
cp -f ../patches/package/900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch
rm -rf ./package/base-files/files/etc/init.d/boot
wget -P package/base-files/files/etc/init.d https://raw.githubusercontent.com/project-openwrt/openwrt/18.06-kernel5.4/package/base-files/files/etc/init.d/boot

#Patch FireWall 以增添fullcone功能
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/fullconenat.patch

# Patch LuCI 以增添fullcone开关
pushd feeds/luci
wget -O- https://github.com/LGA1150/fullconenat-fw3-patch/raw/master/luci.patch | git apply
popd
# Patch Kernel 以解决fullcone冲突
pushd target/linux/generic/hack-5.4
#wget https://raw.githubusercontent.com/project-openwrt/openwrt/18.06-kernel5.4/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
wget https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
popd

#Patch FireWall 以增添SFE
patch -p1 < ../patches/package/luci-app-firewall_add_sfe_switch.patch

# SFE内核补丁
pushd target/linux/generic/hack-5.4
#wget https://raw.githubusercontent.com/MeIsReallyBa/Openwrt-sfe-flowoffload-linux-5.4/master/999-shortcut-fe-support.patch
wget https://raw.githubusercontent.com/Lienol/openwrt/dev-master/target/linux/generic/hack-5.4/999-01-shortcut-fe-support.patch
#wget https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-5.4/999-shortcut-fe-support.patch
popd

#OC
cp -f ../patches/main/999-unlock-1608mhz-rk3328.patch ./target/linux/rockchip/patches-5.4/999-unlock-1608mhz-rk3328.patch

#IRQ
rm -rf ./target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
cp -f ../patches/script/40-net-smp-affinity ./target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

#更换Node版本
rm -rf ./feeds/packages/lang/node
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node feeds/packages/lang/node
rm -rf ./feeds/packages/lang/node-arduino-firmata
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-arduino-firmata feeds/packages/lang/node-arduino-firmata
rm -rf ./feeds/packages/lang/node-cylon
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-cylon feeds/packages/lang/node-cylon
rm -rf ./feeds/packages/lang/node-hid
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-hid feeds/packages/lang/node-hid
rm -rf ./feeds/packages/lang/node-homebridge
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-homebridge feeds/packages/lang/node-homebridge
rm -rf ./feeds/packages/lang/node-serialport
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport feeds/packages/lang/node-serialport
rm -rf ./feeds/packages/lang/node-serialport-bindings
svn co https://github.com/nxhack/openwrt-node-packages/trunk/node-serialport-bindings feeds/packages/lang/node-serialport-bindings

#更换GCC版本
rm -rf ./feeds/packages/devel/gcc
svn co https://github.com/openwrt/packages/trunk/devel/gcc feeds/packages/devel/gcc

#更换Golang版本
rm -rf ./feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/trunk/lang/golang feeds/packages/lang/golang

#crypto
echo '
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_NEON=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_DEV_CCREE=y
CONFIG_CRYPTO_DEV_HISI_SEC=y
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_DRBG_CTR=y
CONFIG_CRYPTO_DRBG_HASH=y
CONFIG_CRYPTO_DRBG_HMAC=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_LIB_DES=y
CONFIG_CRYPTO_LIB_SHA256=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_NHPOLY1305=y
CONFIG_CRYPTO_NHPOLY1305_NEON=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
CONFIG_CRYPTO_SHA3=y
CONFIG_CRYPTO_SHA3_ARM64=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SHA512_ARM64_CE=y
CONFIG_CRYPTO_SIMD=y
CONFIG_CRYPTO_SM3=y
CONFIG_CRYPTO_SM3_ARM64_CE=y
CONFIG_CRYPTO_SM4=y
CONFIG_CRYPTO_SM4_ARM64_CE=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_AEAD=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_RNG=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_XTS=y
CONFIG_SG_SPLIT=y
' >> ./target/linux/rockchip/armv8/config-5.4

##############################

#Additional package

#beardropper
git clone https://github.com/NateLol/luci-app-beardropper package/luci-app-beardropper
sed -i 's/"luci.fs"/"luci.sys".net/g' package/luci-app-beardropper/luasrc/model/cbi/beardropper/setting.lua
sed -i '/firewall/d' package/luci-app-beardropper/root/etc/uci-defaults/luci-beardropper

#luci-app-freq
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/luci-app-cpufreq package/lean/luci-app-cpufreq
patch -p1 < ../patches/package/luci-app-freq.patch

#京东签到
git clone https://github.com/jerrykuku/node-request package/new/node-request
git clone https://github.com/jerrykuku/luci-app-jd-dailybonus package/new/luci-app-jd-dailybonus

#arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind

#访问控制
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-accesscontrol package/lean/luci-app-accesscontrol

#AutoCore
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/autocore package/lean/autocore
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/coremark package/lean/coremark
sed -i 's,-DMULTIT,-Ofast -DMULTIT,g' package/lean/coremark/Makefile
sed -i '9,$d' package/lean/coremark/coremark.sh

#oled
git clone -b master --single-branch https://github.com/NateLol/luci-app-oled package/new/luci-app-oled

#网易云解锁
git clone -b master --single-branch https://github.com/project-openwrt/luci-app-unblockneteasemusic package/new/UnblockNeteaseMusic

#Argon主题
git clone -b master --single-branch https://github.com/jerrykuku/luci-theme-argon package/new/luci-theme-argon

#Edge主题
git clone -b master --single-branch https://github.com/garypang13/luci-theme-edge package/new/luci-theme-edge

#AdGuard
cp -rf ../openwrt-lienol/package/diy/luci-app-adguardhome ./package/new/luci-app-adguardhome
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ntlf9t/AdGuardHome package/new/AdGuardHome

#订阅转换
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/subconverter package/new/subconverter
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/jpcre2 package/new/jpcre2
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/rapidjson package/new/rapidjson
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/duktape package/new/duktape

#流量监视
git clone -b master --single-branch https://github.com/brvphoenix/wrtbwmon package/new/wrtbwmon
git clone -b master --single-branch https://github.com/brvphoenix/luci-app-wrtbwmon package/new/luci-app-wrtbwmon

#OpenClash
svn co https://github.com/vernesong/OpenClash/branches/master/luci-app-openclash package/new/luci-app-openclash
mkdir -p package/base-files/files/etc/openclash/core
cd package/base-files/files/etc/openclash/core
curl -L https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-armv8.tar.gz | tar zxf -
chmod +x clash
cd ../../../../../..

#SmartDNS
svn co https://github.com/pymumu/smartdns/trunk/package/openwrt package/new/smartdns
git clone -b lede --single-branch https://github.com/pymumu/luci-app-smartdns package/new/luci-app-smartdns/

#Syncthing
git clone https://github.com/gyj1109/luci-app-syncthing package/gyj1109/luci-app-syncthing
sed -i "s/PKG_HASH:=.*/PKG_HASH:=skip/g" feeds/packages/utils/syncthing/Makefile
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(curl --silent "https://api.github.com/repos/syncthing/syncthing/releases/latest" | jq ".tag_name" | sed -E 's/^.*"v([^"]+)".*$/\1/')/g" feeds/packages/utils/syncthing/Makefile
sed -i 's,/etc/syncthing,/etc/syncthing/cert.pem\n/etc/syncthing/config.xml\n/etc/syncthing/https-cert.pem\n/etc/syncthing/https-key.pem\n/etc/syncthing/key.pem,g' feeds/packages/utils/syncthing/Makefile

#上网APP过滤
git clone -b master --single-branch https://github.com/destan19/OpenAppFilter package/new/OpenAppFilter

#补全部分依赖（实际上并不会用到）
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/utils/fuse package/utils/fuse
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/network/services/samba36 package/network/services/samba36
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/libs/libconfig package/libs/libconfig

#Collectd
rm -rf ./feeds/packages/utils/collectd
svn co https://github.com/openwrt/packages/trunk/utils/collectd feeds/packages/utils/collectd
sed -i 's/TARGET_x86_64/TARGET_x86_64||TARGET_rockchip/g' feeds/packages/utils/collectd/Makefile

#FullCone模块
cp -rf ../openwrt-lienol/package/network/fullconenat ./package/network/fullconenat

#翻译及部分功能优化
git clone -b master --single-branch https://github.com/QiuSimons/addition-trans-zh package/lean/lean-translate

#SFE
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/new/shortcut-fe
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/fast-classifier package/new/fast-classifier

#回滚zstd
rm -rf ./feeds/packages/utils/zstd
svn co https://github.com/QiuSimons/Others/trunk/zstd feeds/packages/utils/zstd

##############################

#Adbyby
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-adbyby-plus package/lean/luci-app-adbyby-plus
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/adbyby package/lean/coremark/adbyby

#迅雷快鸟
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-xlnetacc package/lean/luci-app-xlnetacc

#DDNS
# rm -rf ./feeds/packages/net/ddns-scripts
# rm -rf ./feeds/luci/applications/luci-app-ddns
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ddns-scripts_aliyun package/lean/ddns-scripts_aliyun
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ddns-scripts_dnspod package/lean/ddns-scripts_dnspod
# svn co https://github.com/openwrt/packages/branches/openwrt-18.06/net/ddns-scripts feeds/packages/net/ddns-scripts
# svn co https://github.com/openwrt/luci/branches/openwrt-18.06/applications/luci-app-ddns feeds/luci/applications/luci-app-ddns

#定时重启
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-autoreboot package/lean/luci-app-autoreboot

#ChinaDNS
# git clone -b luci --single-branch https://github.com/pexcn/openwrt-chinadns-ng package/new/luci-chinadns-ng
# git clone -b master --single-branch https://github.com/pexcn/openwrt-chinadns-ng package/new/chinadns-ng

#SSRP
# svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus
# rm -rf ./package/lean/luci-app-ssr-plus/luasrc/view/shadowsocksr/ssrurl.htm
# wget -P package/lean/luci-app-ssr-plus/luasrc/view/shadowsocksr https://raw.githubusercontent.com/QiuSimons/Others/master/luci-app-ssr-plus/luasrc/view/shadowsocksr/ssrurl.htm
# #rm -rf ./package/lean/luci-app-ssr-plus/root/etc/init.d/shadowsocksr
# #wget -P package/lean/luci-app-ssr-plus/root/etc/init.d https://raw.githubusercontent.com/QiuSimons/Others/master/luci-app-ssr-plus-177-1/root/etc/init.d/shadowsocksr
# #SSRP依赖
# rm -rf ./feeds/packages/net/kcptun
# rm -rf ./feeds/packages/net/shadowsocks-libev
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shadowsocksr-libev package/lean/shadowsocksr-libev
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/pdnsd-alt package/lean/pdnsd
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/v2ray package/lean/v2ray
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/kcptun package/lean/kcptun
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/v2ray-plugin package/lean/v2ray-plugin
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/srelay package/lean/srelay
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/microsocks package/lean/microsocks
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/dns2socks package/lean/dns2socks
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/redsocks2 package/lean/redsocks2
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/proxychains-ng package/lean/proxychains-ng
# #git clone -b master --single-branch https://github.com/pexcn/openwrt-ipt2socks package/lean/ipt2socks
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/ipt2socks package/lean/ipt2socks
# #git clone -b master --single-branch https://github.com/aa65535/openwrt-simple-obfs package/lean/simple-obfs
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/simple-obfs package/lean/simple-obfs
# svn co https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev package/lean/shadowsocks-libev
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/trojan package/lean/trojan
# svn co https://github.com/project-openwrt/openwrt/trunk/package/lean/tcpping package/lean/tcpping

#PASSWALL
# svn co https://github.com/Lienol/openwrt-package/trunk/lienol/luci-app-passwall package/new/luci-app-passwall
# cp -f ../patches/script/move_2_services.sh ./package/new/luci-app-passwall/move_2_services.sh
# pushd package/new/luci-app-passwall
# bash move_2_services.sh
# popd
# svn co https://github.com/Lienol/openwrt-package/trunk/package/tcping package/new/tcping
# svn co https://github.com/Lienol/openwrt-package/trunk/package/trojan-go package/new/trojan-go
# svn co https://github.com/Lienol/openwrt-package/trunk/package/brook package/new/brook
# svn co https://github.com/Lienol/openwrt-package/trunk/package/trojan-plus package/new/trojan-plus

#打印机
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-usb-printer package/lean/luci-app-usb-printer

#流量监管
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-netdata package/lean/luci-app-netdata

#SeverChan
# git clone -b master --single-branch https://github.com/tty228/luci-app-serverchan package/new/luci-app-serverchan
# svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/network/utils/iputils package/network/utils/iputils

#Docker
# svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman package/luci-app-dockerman
# svn co https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker package/luci-lib-docker
# svn co https://github.com/openwrt/packages/trunk/utils/docker-ce package/utils/docker-ce
# svn co https://github.com/openwrt/packages/trunk/utils/cgroupfs-mount package/utils/cgroupfs-mount
# svn co https://github.com/openwrt/packages/trunk/utils/containerd package/utils/containerd
# svn co https://github.com/openwrt/packages/trunk/utils/libnetwork package/utils/libnetwork
# svn co https://github.com/openwrt/packages/trunk/utils/tini package/utils/tini
# svn co https://github.com/openwrt/packages/trunk/utils/runc package/utils/runc
# rm -rf ./package/lang/golang
# svn co https://github.com/openwrt/packages/trunk/lang/golang package/lang/golang

#IPSEC
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-ipsec-vpnd package/lean/luci-app-ipsec-vpnd

#Zerotier
# svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/luci-app-zerotier package/lean/luci-app-zerotier
# cp -f ../patches/script/move_2_services.sh ./package/lean/luci-app-zerotier/move_2_services.sh
# pushd package/lean/luci-app-zerotier
# bash move_2_services.sh
# popd

#frp
# rm -f ./feeds/luci/applications/luci-app-frps
# rm -f ./feeds/luci/applications/luci-app-frpc
# rm -rf ./feeds/packages/net/frp
# rm -f ./package/feeds/packages/frp
# git clone https://github.com/lwz322/luci-app-frps.git package/lean/luci-app-frps
# git clone https://github.com/kuoruan/luci-app-frpc.git package/lean/luci-app-frpc
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/frp package/feeds/packages/frp

##############################



#最后的收尾工作

#禁用IPv6
sed -i 's/exit 0/uci delete network.lan.ip6assign\nuci delete network.wan6\nuci delete dhcp.lan.ra\nuci delete dhcp.lan.dhcpv6\nuci delete dhcp.lan.ndp\nuci commit\nuci commit dhcp\nuci commit network\n\nexit 0/g' package/lean/lean-translate/files/zzz-default-settings

#署名
sed -i '$d' package/lean/lean-translate/files/zzz-default-settings
echo "sed -i '/DISTRIB_REVISION/d' /etc/openwrt_release\necho \"DISTRIB_REVISION='BUILDVERSION'\" >> /etc/openwrt_release\nsed -i '/DISTRIB_DESCRIPTION/d' /etc/openwrt_release\necho \"DISTRIB_DESCRIPTION='Gyj1109 Build @ BUILDVERSION'\" >> /etc/openwrt_release\n\nexit 0" >> package/lean/lean-translate/files/zzz-default-settings

#最大连接
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

#删除已有配置
rm -rf .config

#授予权限
chmod -R 755 ./

exit 0
