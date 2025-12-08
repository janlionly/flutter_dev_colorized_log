# 发布检查清单 - v2.0.7

## ✅ 已完成的更新

### 1. 版本更新
- [x] `pubspec.yaml` 版本更新为 `2.0.7`
- [x] 包通过 `flutter pub publish --dry-run` 验证，0 个警告

### 2. CHANGELOG.md
- [x] 添加了 v2.0.7 的更新日志
- [x] 详细说明了新功能：`printOnceIfContains` 参数
- [x] 包含使用示例和场景说明

### 3. README.md
- [x] 更新了版本引用（V 2.0.7）
- [x] 添加了详细的 `printOnceIfContains` 功能说明
- [x] 包含实际应用场景和代码示例

### 4. 代码质量
- [x] 所有源代码文件无 linter 错误
- [x] 添加了完整的单元测试
- [x] 所有方法都支持新参数

## 📦 新功能摘要 (v2.0.7)

### `printOnceIfContains` 参数
- **功能**: 只打印第一条包含指定关键词的日志，后续包含相同关键词的日志自动跳过
- **适用范围**: 所有日志方法（log, print, exe, logInfo, logSuccess, logWarning, logError, logBlink, exe* 系列）
- **使用场景**: 
  - 防止循环中的重复错误日志
  - 用户行为追踪（每个用户 ID 只记录一次）
  - 错误代码去重

### 新增方法
- `Dev.clearCachedKeys()` - 清除所有缓存的关键词

## 🚀 发布步骤

### 方式一：使用 fvm（如果已配置）
```bash
cd /Users/anker/dev_myparty/flutter_dev_colorized_log
fvm flutter pub publish
```

### 方式二：使用系统 Flutter
```bash
cd /Users/anker/dev_myparty/flutter_dev_colorized_log
flutter pub publish
```

## 📝 发布后操作

1. 确认发布成功后，在 GitHub 上创建 v2.0.7 tag
2. 在 GitHub Releases 中发布新版本
3. 将 CHANGELOG.md 内容复制到 Release Notes

## 🔍 发布前最后检查

- [x] 版本号已更新（2.0.7）
- [x] CHANGELOG.md 已更新
- [x] README.md 已更新
- [x] 所有代码无 linter 错误
- [x] 单元测试已添加并通过
- [x] dry-run 验证通过（0 warnings）
- [ ] Git commit 并 push 到远程仓库
- [ ] 准备好 pub.dev 账号和令牌

## 📊 包信息

- **包名**: dev_colorized_log
- **版本**: 2.0.7
- **主页**: https://github.com/janlionly/flutter_dev_colorized_log
- **支持平台**: Android, iOS, Linux, macOS, Windows, Web
- **Dart SDK**: >=2.17.0 <4.0.0
- **Flutter SDK**: >=1.17.0

---

**注意**: 发布到 pub.dev 后无法撤回，请确认所有更改正确无误后再执行发布命令。

