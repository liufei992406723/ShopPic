# ShopPic 搭建指南（一条命令）

## 前提

- Mac 电脑
- Xcode 15+

## 第一步：安装 XcodeGen（一次性）

```bash
brew install xcodegen
```

## 第二步：生成 Xcode 项目

```bash
cd /path/to/ShopPic    # 这个文件夹
xcodegen generate
```

会生成 `ShopPic.xcodeproj`。

## 第三步：打开项目

```bash
open ShopPic.xcodeproj
```

## 第四步：设置签名

在 Xcode 中：
1. 选中 ShopPic target → Signing & Capabilities → Team 选你的 Apple ID
2. 选中 ShareExtension target → 同样设置 Team
3. App Groups 已经配好了（`group.com.shoppic.app`）

## 第五步：跑起来

- 连接 iPhone（iOS 16+）
- Cmd+R 运行到真机
- 测试分享：相册选图 → 分享 → 找到 ShopPic

## 可选：换 Bundle ID

如果你的 Bundle ID 不是 `com.shoppic.app`，需要改 3 个地方：
- `project.yml` 中的 `bundleIdPrefix`
- `Shared/AppGroupConstants.swift` 中的 `appGroupID`
- `ShopPic.entitlements` 和 `ShareExtension.entitlements` 中的 App Group ID

## 可上架 App Store

- 隐私清单 `PrivacyInfo.xcprivacy` 已配好
- 无网络请求，无数据收集
- 只用了公开的 `UIApplication.open()` API
