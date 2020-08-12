cp -f ../files/999-unlock-1608mhz-rk3328.patch ./target/linux/rockchip/patches-5.4/999-unlock-1608mhz-rk3328.patch
rm -f ./target/linux/rockchip/patches-5.4/004-unlock-1512mhz-rk3328.patch
sed -i 's/Os/O3/g' include/target.mk
sed -i 's/O2/O3/g' ./rules.mk
sed -i 's/16384/65536/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

sed -i "s/PKG_HASH:=.*/PKG_HASH:=skip/g" feeds/packages/net/ariang/Makefile
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(curl --silent "https://api.github.com/repos/mayswind/AriaNg/releases/latest" | jq ".tag_name" | sed -E 's/^.*"([^"]+)".*$/\1/')/g" feeds/packages/net/ariang/Makefile

sed -i 's/TARGET_x86_64/TARGET_x86_64||TARGET_rockchip/g' feeds/packages/utils/collectd/Makefile

sed -i 's,-DMULTIT,-Ofast -DMULTIT,g' package/lean/coremark/Makefile
sed -i '9,$d' package/lean/coremark/coremark.sh

git clone https://github.com/gyj1109/luci-app-syncthing package/gyj1109/luci-app-syncthing
sed -i "s/PKG_HASH:=.*/PKG_HASH:=skip/g" feeds/packages/utils/syncthing/Makefile
sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$(curl --silent "https://api.github.com/repos/syncthing/syncthing/releases/latest" | jq ".tag_name" | sed -E 's/^.*"v([^"]+)".*$/\1/')/g" feeds/packages/utils/syncthing/Makefile
sed -i 's,/etc/syncthing,/etc/syncthing/cert.pem\n/etc/syncthing/config.xml\n/etc/syncthing/https-cert.pem\n/etc/syncthing/https-key.pem\n/etc/syncthing/key.pem,g' feeds/packages/utils/syncthing/Makefile

mkdir -p package/base-files/files/etc/openclash/core
cd package/base-files/files/etc/openclash/core
curl -L https://github.com/vernesong/OpenClash/releases/download/Clash/clash-linux-armv8.tar.gz | tar zxf -
chmod +x clash
cd ../../../../../..