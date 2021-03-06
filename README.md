# 玩客/链克钱包
[![Build Status](https://travis-ci.org/Tuluobo/LKWallet.svg?branch=master)](https://travis-ci.org/Tuluobo/LKWallet)  [![GitHub issues](https://img.shields.io/github/issues/Tuluobo/LKWallet.svg)](https://github.com/Tuluobo/LKWallet/issues)  [![License: Apache-2.0](https://img.shields.io/github/license/Tuluobo/LKWallet.svg)](https://www.apache.org/licenses/LICENSE-2.0)  [![Weibo](https://img.shields.io/badge/weibo-@秃萝卜-yellow.svg?style=flat)](http://weibo.com/210101276)    [![Twitter](https://img.shields.io/twitter/url/https/github.com/Tuluobo/LKWallet.svg?style=social)](https://twitter.com/intent/tweet?text=Wow:&url=https%3A%2F%2Fgithub.com%2FTuluobo%2FLKWallet)

<p align="center">
    <img src="https://github.com/Tuluobo/LKWallet/blob/master/screenshot/app_icon.png" width="200" alt="LKWallet" title="LKWallet" />
</p>

## 关于 

LKWallet 是一款迅雷玩客币（链克）查询和账户操作的第三方 App，现在支持无私钥查询余额，交易，创建账户，导入导出，转账，欢迎下载体验，随手 Star 一个，Thanks。

> App Store 地址:  [https://itunes.apple.com/cn/app/玩客钱包/id1302778851](https://itunes.apple.com/cn/app/%e7%8e%a9%e5%ae%a2%e9%92%b1%e5%8c%85/id1302778851)

## 截图

![](./screenshot/1.png)       ![](./screenshot/2.png)      ![](./screenshot/3.png)  ![](./screenshot/4.png)         

## 编译

使用最新的 Cocoapods（version 1.4.0）和 Xcode 9.3 进行编译并运行。

- 首先，下载源代码：
  `git clone https://github.com/Tuluobo/LKWallet.git`

- 使用终端切换到项目目路，执行：
  `pod install`

  > 如果没有安装 `CocoaPods` 请 Google 搜索安装教程安装。


- 打开 `LKWallet.xcworkspace` Build, Run。

## 功能 TODO

已完成功能：

- [x] 账户余额查询
- [x] 账户交易查询
- [x] 钱包文件导入
- [x] 钱包文件导出
- [x] 账户修改密码
- [x] 转账 (目前提交的代码中实现的方法迅雷没有禁止大陆转账之前的接口，目前迅雷已经限制了大陆 IP 的访问，所以代码开发完成了，但是不能转账，后面会使用 JSONRPC 的方式)

欢迎大家继续提出好玩的功能，我会根据能力在 App 中实现。

## License

Apache-2.0
