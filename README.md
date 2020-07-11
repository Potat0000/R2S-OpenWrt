# NanoPi R2S OpenWrt 固件自动编译

喜欢记得右上角Star哟！！

### 发布地址

https://github.com/gyj1109/R2S-OpenWrt/releases

#### 刷入帮助

* 使用 [Rufus](https://rufus.ie/) 刷写时需解压出`.img`文件后刷入

### 管理后台

- 地址：192.168.1.1

### Fork方法

1. Fork 到自己的账号下
2. 进入 Actions 界面，启用 Github Actions(**必须要先启用**)
3. 在 [Github Token](https://github.com/settings/tokens) 页面申请 Token (需含有`repo`权限)
4. 在项目 Settings - Secrets 界面，添加一个 Secret 命名为`sec_token`，内容为上一步申请的 Token
5. 在 `origin.seed` 文件中，自定义所需要的软件包
    - 比如需要 luci-app-samba， 那么只要在文件中添加一行 CONFIG_PACKAGE_luci-app-samba=y

*按此方法Fork后编译，**无需**修改workflow文件，并将自动按**您的用户名**生成ROM*

### 贡献

欢迎提出各种Issue，包括但不限于：

* 新模块需求
* Fork后编译失败的帮助
* 新的编译选项（及将部分功能设置成可选择性编译）
* 来自其他R2S编译项目的优秀workflow建议
* ……

此外，一个人精力有限。如果有能力，一定要多提PR哦！

### 感谢

* [quintus-lab/Openwrt-R2S](https://github.com/quintus-lab/Openwrt-R2S)
