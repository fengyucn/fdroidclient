# fdroidclient — 自用构建补丁（不含上游源码）

上游：https://gitlab.com/fdroid/fdroidclient （tag `2.0.3`）
本仓库**只保存自用改装**，不含上游源码：构建时由 abuild 从上游拉取源码，再用这里的补丁重放。

## 内容

- `patches/selfuse.patch`
  - `minSdk` 24 → 36（仅 Android 16+，自用）
  - release 签名改读 `key.properties`（口令与 keystore 均不入库）
  - `maven.google.com` 别名 → `dl.google.com`（集群隧道内前者不可达）
- `apply-patches.sh`：`check` / `apply`，幂等；上游 `app/build.gradle.kts` 变动导致无法干净应用时直接失败
- `check.sh`：供 `bin/proj-index --audit` 调用

## 用法

```bash
# 1. 取上游该版本源码到工程目录后
projects/fdroidclient/apply-patches.sh apply
# 2. 本地准备（不入库）：key.properties(600) + selfuse.jks，storeFile 用绝对路径
```

签名为自用证书，与官方同包名不同签名：安装前须卸载官方 F-Droid。
