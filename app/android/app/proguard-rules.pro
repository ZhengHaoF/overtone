# jni / jnigen 生成的代码在运行时按类名字符串查找 Kotlin 协程类型
# （suspend 方法的 Continuation、COROUTINE_SUSPENDED、Result(Failure)、Unit）。
# R8 一旦改名或裁掉它们，release 包启动时 PlatformException 静默失败：
# shared_preferences / flutter_secure_storage 全不可用，登录态恢复整体降级。
-keep class kotlin.coroutines.** { *; }
-keep class kotlin.Result* { *; }
-keep class kotlin.Unit { *; }
