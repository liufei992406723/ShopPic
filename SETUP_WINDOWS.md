# Windows 搭建指南 — 无需 Mac 编译 iOS App

## 整体流程

```
Windows (你)                     GitHub (免费云 Mac)               iPhone
─────────────                    ────────────────────              ──────
修改代码 → git push  ──────────→  Actions 自动编译  ──────────→  下载 IPA
                                 生成 ShopPic.ipa                  AltStore 安装
```

## 第一步：获得 Apple 签名证书（只需一次）

这一步需要 Apple 开发者证书才能签名。有两个选择：

### 选择 A：Apple Developer Program（$99/年，推荐）

1. 在 [developer.apple.com](https://developer.apple.com) 注册付费账号
2. 证书获取方式（任选一种）：

**方式 1 — 租 1 小时云 Mac（最简单）**
- 去 [MacinCloud](https://www.macincloud.com) 或 [MacWeb](https://macweb.com) 租 1 小时，约 $5
- 远程桌面登录云 Mac，打开 Xcode
- Xcode → Settings → Accounts → 登录你的 Apple ID
- Xcode → 打开 ShopPic 项目 → 自动创建 Development Certificate + Provisioning Profile
- 在云 Mac 上导出证书为 .p12 文件（Keychain Access → 右键证书 → Export）
- 下载 .p12 文件和 .mobileprovision 文件到你的 Windows

**方式 2 — 用 GitHub Actions 自动创建**
- 把 App Store Connect API Key 配到 GitHub Secrets
- 我会在 workflow 里自动生成新签名

### 选择 B：免费 Apple ID（7 天有效期）

1. 用普通 Apple ID 登录 developer.apple.com（免费）
2. 同样需要云 Mac 或朋友帮忙生成证书
3. 签名 7 天后过期，需重新编译安装

## 第二步：创建 GitHub 仓库

```bash
# 在你 Windows 上
cd E:\Projects\huarongdao\ShopPic
git init
git add .
git commit -m "Init"
```

在 github.com 创建新仓库（例如 `yourname/ShopPic`），然后：

```bash
git remote add origin https://github.com/yourname/ShopPic.git
git push -u origin main
```

## 第三步：配置 GitHub Secrets

在 GitHub 仓库页面 → Settings → Secrets and variables → Actions → New repository secret：

| Secret 名称 | 内容 |
|------------|------|
| `BUILD_CERT_BASE64` | 运行 `certutil -encode cert.p12 tmp && type tmp` 得到的 Base64 字符串 |
| `BUILD_CERT_PASSWORD` | 导出 .p12 时设置的密码 |
| `BUILD_PROVISION_PROFILE_BASE64` | 运行 `certutil -encode xxx.mobileprovision tmp && type tmp` 得到的 Base64 |
| `DEVELOPMENT_TEAM` | 你的 Team ID（developer.apple.com → Membership 里找） |

## 第四步：触发编译

- 推送代码到 GitHub → `git push` → 自动开始编译
- 或者手动：GitHub → Actions → Build iOS IPA → Run workflow

编译完成后（约 10 分钟），在 Actions 页面下载 `ShopPic.ipa` 到 Windows。

## 第五步：安装到 iPhone

### 用 AltStore（Windows 上运行）

1. 下载 [AltStore](https://altstore.io) Windows 版
2. 安装 AltServer 到你的 Windows
3. iPhone 通过 USB 连接，信任此电脑
4. AltServer 托盘图标 → Install AltStore → 选你的 iPhone
5. 输入 Apple ID 和密码（用于签名）
6. iPhone 上出现 AltStore App
7. 把下载的 ShopPic.ipa 发送到 iPhone（通过微信/AirDrop）
8. 在 AltStore 里点 + → 选 ShopPic.ipa → 安装

### 备选：SideStore（WiFi 安装，更灵活）
- [SideStore.io](https://sidestore.io) 类似 AltStore，但不需要电脑在同一网络

## 每次更新 App

```bash
# 改了代码后
git add .
git commit -m "Update"
git push

# 等待 GitHub Actions 编译完成（约 10 分钟）
# 下载新 IPA → AltStore 安装更新
```

## 注意事项

- 免费 Apple ID 签名 7 天过期，到期前用 AltStore 的 Refresh All 续签
- 付费账号签名 1 年有效
- GitHub Actions 每月免费 2000 分钟，单次编译约 10 分钟，够用 200 次
- 如果换 Bundle ID，需要同步更新：
  - `project.yml` → `bundleIdPrefix`
  - `Shared/AppGroupConstants.swift` → `appGroupID`
  - `.entitlements` 文件

## 简化版流程图

```
[修改代码] → [git push] → [GitHub Actions 自动编译 10min]
                              ↓
                        [下载 IPA 到 Windows]
                              ↓
                    [AltStore 安装到 iPhone]
                              ↓
                         [开始搜同款]
```
