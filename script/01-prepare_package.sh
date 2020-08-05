#!/bin/bash
clear
rm -f ./feeds.conf.default
wget https://raw.githubusercontent.com/openwrt/openwrt/master/feeds.conf.default
#Update feed
./scripts/feeds update -a && ./scripts/feeds install -a
#O3
sed -i 's/Os/O3/g' include/target.mk
sed -i 's/O2/O3/g' ./rules.mk
#irqbalance
sed -i 's/0/1/g' feeds/packages/utils/irqbalance/files/irqbalance.config
#Patch rk-crypto
patch -p1 < ../patches/kernel_crypto-add-rk3328-crypto-support.patch
#Patch i2c0
cp -f ../patches/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch ./target/linux/rockchip/patches-5.4/998-rockchip-enable-i2c0-on-NanoPi-R2S.patch
#Patch jsonc
patch -p1 < ../patches/use_json_object_new_int64.patch
#Patch dnsmasq aaaa filter
patch -p1 < ../patches/dnsmasq-add-filter-aaaa-option.patch
patch -p1 < ../patches/luci-add-filter-aaaa-option.patch
cp -f ../patches/900-add-filter-aaaa-option.patch ./package/network/services/dnsmasq/patches/900-add-filter-aaaa-option.patch
#Patch fullCone
git clone -b master --single-branch https://github.com/QiuSimons/openwrt-fullconenat package/fullconenat
#Patch FireWall for fullcone
mkdir package/network/config/firewall/patches
wget -P package/network/config/firewall/patches/ https://raw.githubusercontent.com/LGA1150/fullconenat-fw3-patch/master/fullconenat.patch
#Patch LuCI for fullcone
pushd feeds/luci
wget -O - https://raw.githubusercontent.com/LGA1150/fullconenat-fw3-patch/master/luci.patch | git apply
popd
#Patch Kernel for fullcone
pushd target/linux/generic/hack-5.4
wget https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-5.4/952-net-conntrack-events-support-multiple-registrant.patch
popd
#Patch FireWall for SFE
patch -p1 < ../patches/luci-app-firewall_add_sfe_switch.patch
#Patch SFE kernel
pushd target/linux/generic/hack-5.4
wget https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/generic/hack-5.4/999-shortcut-fe-support.patch
popd
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/new/shortcut-fe
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/fast-classifier package/new/fast-classifier
#Overclock to 1.6G
cp -f ../patches/999-unlock-1608mhz-rk3328.patch ./target/linux/rockchip/patches-5.4/999-unlock-1608mhz-rk3328.patch
rm -f ./target/linux/rockchip/patches-5.4/004-unlock-1512mhz-rk3328.patch
#Patch config-5.4 to support docker
echo '
CONFIG_ROCKCHIP_THERMAL=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_NET_PRIO=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_IPVLAN=y
CONFIG_IPVTAP=m
CONFIG_DM_THIN_PROVISIONING=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SHA512_ARM64_CE=y
CONFIG_CRYPTO_SHA3_ARM64=y
CONFIG_CRYPTO_SM3_ARM64_CE=y
CONFIG_CRYPTO_SM4_ARM64_CE=y
CONFIG_CRYPTO_CRCT10DIF_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_AES_ARM64_BS=y
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_CMAC=y
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
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_RNG=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_DEV_ROCKCHIP=y
CONFIG_SND_SOC_ROCKCHIP=m
CONFIG_SND_SOC_ROCKCHIP_I2S=m
CONFIG_SND_SOC_ROCKCHIP_PDM=m
CONFIG_SND_SOC_ROCKCHIP_SPDIF=m
CONFIG_PHY_ROCKCHIP_INNO_USB3=y
CONFIG_USB_DWC2=y
CONFIG_USB_DWC2_DUAL_ROLE=y
' >> ./target/linux/rockchip/armv8/config-5.4

#Update new version GCC
rm -rf ./feeds/packages/devel/gcc
svn co https://github.com/openwrt/packages/trunk/devel/gcc feeds/packages/devel/gcc
#Update new version Golang
rm -rf ./feeds/packages/lang/golang
svn co https://github.com/openwrt/packages/trunk/lang/golang feeds/packages/lang/golang

#Increase max connections
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

#Additional translation
git clone -b master --single-branch https://github.com/QiuSimons/addition-trans-zh package/lean/lean-translate

#Default settings
rm -rf package/lean/lean-translate/files/zzz-default-settings
cp ../script/zzz-default-settings package/lean/lean-translate/files/zzz-default-settings



##############################

#Additional package

#Themes
git clone -b master --single-branch https://github.com/jerrykuku/luci-theme-argon.git package/new/luci-theme-argon
git clone -b master --single-branch https://github.com/garypang13/luci-theme-edge.git package/new/luci-theme-edge

#AppFilter
git clone -b master --single-branch https://github.com/destan19/OpenAppFilter package/new/OpenAppFilter

#Arpbind
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-arpbind package/lean/luci-app-arpbind

#AutoCore
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/autocore package/lean/autocore

#Beardropper
git clone https://github.com/NateLol/luci-app-beardropper package/luci-app-beardropper
#Collectd
sed -i 's/TARGET_x86_64/TARGET_x86_64||TARGET_rockchip/g' feeds/packages/utils/collectd/Makefile

#Coremark
rm -rf ./feeds/packages/utils/coremark
rm -rf ./package/feeds/packages/coremark
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/coremark package/lean/coremark
sed -i 's,-DMULTIT,-Ofast -DMULTIT,g' package/lean/coremark/Makefile
sed -i '9,$d' package/lean/coremark/coremark.sh

#CPUFreq
svn co https://github.com/project-openwrt/openwrt/branches/master/package/lean/luci-app-cpufreq package/lean/luci-app-cpufreq
patch -p1 < ../patches/luci-app-freq.patch

#iputils (Some important network tools)
svn co https://github.com/openwrt/openwrt/branches/openwrt-19.07/package/network/utils/iputils package/network/utils/iputils

#OLED display
git clone https://github.com/natelol/luci-app-oled package/natelol/luci-app-oled

#Onliner
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/luci-app-onliner package/ctcgfw/luci-app-onliner

#OpenClash
git clone -b master --single-branch https://github.com/vernesong/OpenClash.git OpenClash
mkdir -p package/vernesong
mv OpenClash/luci-app-openclash package/vernesong/luci-app-openclash
rm -rf OpenClash
mkdir -p package/base-files/files/etc/openclash/core
cd package/base-files/files/etc/openclash/core
curl -L https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-armv8.tar.gz | tar zxf -
chmod +x clash
cd ../../../../../..

#SmartDNS
svn co https://github.com/pymumu/smartdns/trunk/package/openwrt package/new/smartdns/smartdns
svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ntlf9t/luci-app-smartdns package/new/smartdns/luci-app-smartdns

#Syncthing
git clone https://github.com/gyj1109/luci-app-syncthing package/gyj1109/luci-app-syncthing
sed -i "s/PKG_HASH:=.*/PKG_HASH:=skip/g" feeds/packages/utils/syncthing/Makefile
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(curl --silent "https://api.github.com/repos/syncthing/syncthing/releases/latest" | jq ".tag_name" | sed -E 's/^.*"v([^"]+)".*$/\1/')/g" feeds/packages/utils/syncthing/Makefile
sed -i 's,/etc/syncthing,/etc/syncthing/cert.pem\n/etc/syncthing/config.xml\n/etc/syncthing/https-cert.pem\n/etc/syncthing/https-key.pem\n/etc/syncthing/key.pem,g' feeds/packages/utils/syncthing/Makefile

#Wrtbwmon (Traffic monitoring)
git clone -b master --single-branch https://github.com/brvphoenix/wrtbwmon package/new/wrtbwmon
git clone -b master --single-branch https://github.com/brvphoenix/luci-app-wrtbwmon package/new/luci-app-wrtbwmon

##############################

#AdGuard
# git clone -b master --single-branch https://github.com/rufengsuixing/luci-app-adguardhome package/new/luci-app-adguardhome

#AutoReboot
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-autoreboot package/lean/luci-app-autoreboot

#Dockerman
# git clone https://github.com/lisaac/luci-app-dockerman.git package/lean/luci-app-dockerman
# git clone https://github.com/lisaac/luci-lib-docker package/lean/luci-lib-docker
# svn co https://github.com/openwrt/packages/trunk/utils/docker-ce package/lean/docker-ce
# svn co https://github.com/openwrt/packages/trunk/utils/cgroupfs-mount package/lean/cgroupfs-mount
# svn co https://github.com/openwrt/packages/trunk/utils/libnetwork package/lean/libnetwork
# svn co https://github.com/openwrt/packages/trunk/utils/tini package/lean/tini
# svn co https://github.com/openwrt/packages/trunk/utils/containerd package/lean/containerd
# svn co https://github.com/openwrt/packages/trunk/utils/runc package/lean/runc
# svn co https://github.com/openwrt/packages/trunk/lang/golang package/lang/golang

#FileTransfer
# svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/lean/luci-app-filetransfer package/lean/luci-app-filetransfer
# svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/lean/luci-lib-fs package/lean/luci-lib-fs

#Passwall
# svn co https://github.com/Lienol/openwrt-package/trunk/lienol/luci-app-passwall package/lienol/luci-app-passwall
# git clone -b master --single-branch https://github.com/xnxy2012/luci-app-passwall.git package/lienol/luci-app-passwall
#Passwall Depends
# svn co https://github.com/Lienol/openwrt-package/trunk/package/chinadns-ng package/lienol/chinadns-ng
# svn co https://github.com/Lienol/openwrt-package/trunk/package/tcping package/lienol/tcping
# svn co https://github.com/Lienol/openwrt-package/trunk/package/trojan-go package/lienol/trojan-go
# svn co https://github.com/Lienol/openwrt-package/trunk/package/dns2socks package/lienol/dns2socks
# svn co https://github.com/Lienol/openwrt-package/trunk/package/v2ray-plugin package/lienol/v2ray-plugin
# svn co https://github.com/Lienol/openwrt-package/trunk/package/pdnsd-alt package/lienol/pdnsd-alt
# svn co https://github.com/Lienol/openwrt-package/trunk/package/openssl1.1 package/lienol/openssl1.1
# svn co https://github.com/Lienol/openwrt-package/trunk/package/simple-obfs package/lienol/simple-obfs

#Printer
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-usb-printer package/lean/luci-app-usb-printer

#SeverChan
# git clone -b master --single-branch https://github.com/tty228/luci-app-serverchan package/new/luci-app-serverchan

#SSRP
# svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus
# rm -rf ./package/lean/luci-app-ssr-plus/luasrc/view/shadowsocksr/ssrurl.htm
# wget -P package/lean/luci-app-ssr-plus/luasrc/view/shadowsocksr https://raw.githubusercontent.com/QiuSimons/Others/master/luci-app-ssr-plus/luasrc/view/shadowsocksr/ssrurl.htm
# #SSRP Depends
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
# git clone -b master --single-branch https://github.com/pexcn/openwrt-ipt2socks package/lean/ipt2socks
# git clone -b master --single-branch https://github.com/aa65535/openwrt-simple-obfs package/lean/simple-obfs
# svn co https://github.com/coolsnowwolf/packages/trunk/net/shadowsocks-libev package/lean/shadowsocks-libev
# svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/trojan package/lean/trojan
# svn co https://github.com/project-openwrt/openwrt/trunk/package/lean/tcpping package/lean/tcpping

#SubConverter
# svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/subconverter package/new/subconverter
# svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/jpcre2 package/new/jpcre2
# svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/rapidjson package/new/rapidjson

#Tmate (A terminal)
# svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/tmate package/ctcgfw/tmate
# svn co https://github.com/project-openwrt/openwrt/branches/openwrt-19.07/package/ctcgfw/msgpack-c package/ctcgfw/msgpack-c

#Transmission (BT)
# rm -rf ./feeds/packages/net/transmission*
# rm -rf ./feeds/luci/applications/luci-app-transmission/
# svn co https://github.com/coolsnowwolf/packages/trunk/net/transmission feeds/packages/net/transmission
# svn co https://github.com/coolsnowwolf/packages/trunk/net/transmission-web-control feeds/packages/net/transmission-web-control
# svn co https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-transmission feeds/luci/applications/luci-app-transmission

##############################



#生成默认配置及缓存
rm -rf .config

exit 0
