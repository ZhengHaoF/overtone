#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>

#include "desktop_media_host.h"
#include "taskbar_host.h"
#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject &project);
  virtual ~FlutterWindow();

protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

private:
  void RegisterTaskbarChannel();

  /// 第二个进程启动时，main.cpp 广播 Overtone.Activate；主窗收到后把自己
  /// 唤回前台（优先交给 Dart 走 windowManager.show()，通道未就绪时退回 Win32）。
  void HandleActivateRequest();

  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      taskbar_channel_;
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
      single_instance_channel_;
  UINT activate_msg_ = 0;
  TaskbarHost taskbar_;
  DesktopMediaHost media_;
  UINT taskbar_created_msg_ = 0;
  UINT taskbar_button_created_msg_ = 0;
};

#endif // RUNNER_FLUTTER_WINDOW_H_
