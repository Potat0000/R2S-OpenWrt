#!/bin/bash

set -eo pipefail
shopt -s extglob

sudo chown -R "$(id -u):$(id -g)" "${HOST_BIN_DIR}"

mv "${HOST_BIN_DIR}/.config" "${HOST_BIN_DIR}/config.seed" || true

if [ "x${OPT_PACKAGE_ONLY}" != "x1" ] && [ "x${TEST}" != "x1" ]; then
  mkdir "${HOST_WORK_DIR}/openwrt_firmware"
  cd "${HOST_BIN_DIR}/targets/"*/*
  all_firmware_files=( !(packages) )
  [ ${#all_firmware_files[@]} -gt 0 ] && mv "${all_firmware_files[@]}" "${HOST_WORK_DIR}/openwrt_firmware/" || true

  cp "${HOST_BIN_DIR}/config.seed" "${HOST_WORK_DIR}/openwrt_firmware/" || true

  cd "${HOST_WORK_DIR}"
  mkdir -p "${HOST_WORK_DIR}/firmware"
  mv openwrt_firmware/openwrt-*-squashfs-sysupgrade.img.gz firmware/
  mv openwrt_firmware/config.seed firmware/

  cd firmware
  gzip -d *.gz || true
  echo -e "MD5:    \c" > checksums
  md5sum *.img | grep squashfs | cut -d " " -f 1 >> checksums
  echo -e "SHA256: \c" >> checksums
  sha256sum *.img | grep squashfs | cut -d " " -f 1 >> checksums
  gzip *.img

  cp checksums "${HOST_WORK_DIR}/body.md"
  sed -i 's/:\ \+/: /g' "${HOST_WORK_DIR}/body.md"
  sed -i '1iBuilt at BUILDTIME' "${HOST_WORK_DIR}/body.md"
  zip -r "${HOST_WORK_DIR}/BUILDUSER-${BUILD_TARGET}-BUILDTIME-Firmware.zip" *
fi

cd "${HOST_BIN_DIR}"
zip -r "${HOST_WORK_DIR}/BUILDUSER-${BUILD_TARGET}-BUILDTIME-Package" *

echo "::set-output name=status::success"
