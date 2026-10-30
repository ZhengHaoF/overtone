#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <cstdint>
#include <sstream>
#include <string>

#include "app_identity.h"
#include "flutter_window.h"
#include "utils.h"

namespace {

// 单实例唤醒消息：两个进程用同一个名字 RegisterWindowMessageW，拿到的 id 一致。
constexpr wchar_t kActivateMessage[] = L"Overtone.Activate";

// 互斥量按 exe 路径区分：同一份程序只允许一个实例，Debug / Release / 绿色包
// 各自可以并行（开发时 flutter run 与安装版互不打扰）。Local\ 前缀让不同
// Windows 登录会话互不干扰。
std::wstring SingleInstanceMutexName() {
  wchar_t buffer[MAX_PATH * 4] = {};
  const DWORD length =
      ::GetModuleFileNameW(nullptr, buffer, static_cast<DWORD>(sizeof(buffer) / sizeof(buffer[0])));
  std::wstring path(buffer, length);
  ::CharLowerBuffW(path.data(), static_cast<DWORD>(path.size()));

  // FNV-1a（按 UTF-16 低/高字节拆开喂），结果稳定，不依赖 std::hash 的实现。
  uint64_t hash = 1469598103934665603ull;
  for (const wchar_t unit : path) {
    for (const unsigned shift : {0u, 8u}) {
      hash ^= static_cast<uint64_t>((unit >> shift) & 0xFF);
      hash *= 1099511628211ull;
    }
  }

  std::wostringstream name;
  name << L"Local\\Overtone.SingleInstance." << std::hex << hash;
  return name.str();
}

/// true 表示已有实例：已把「激活」广播出去，调用方应直接退出。
bool ActivateExistingInstance() {
  const UINT message = ::RegisterWindowMessageW(kActivateMessage);
  if (message == 0) {
    return false;
  }
  // 第二个进程是被用户刚点起来的，持有前台权限；把它让给已有实例，
  // 否则 SetForegroundWindow 会被 Windows 的前台锁挡掉。
  ::AllowSetForegroundWindow(ASFW_ANY);
  // 首个实例可能还没建好窗口，广播连发几次兜住这个窗口期。
  for (int attempt = 0; attempt < 3; ++attempt) {
    ::PostMessageW(HWND_BROADCAST, message, 0, 0);
    ::Sleep(120);
  }
  return true;
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  const bool lyric_process = IsDesktopLyricProcess();

  // 歌词窗由主进程拉起，必须豁免单实例判断；其余情况按 exe 路径判重。
  HANDLE single_instance_mutex = nullptr;
  if (!lyric_process) {
    const std::wstring mutex_name = SingleInstanceMutexName();
    single_instance_mutex = ::CreateMutexW(nullptr, TRUE, mutex_name.c_str());
    if (single_instance_mutex != nullptr &&
        ::GetLastError() == ERROR_ALREADY_EXISTS) {
      ActivateExistingInstance();
      ::CloseHandle(single_instance_mutex);
      ::CoUninitialize();
      return EXIT_SUCCESS;
    }
  }

  if (!lyric_process) {
    // Must run before any SMTC / taskbar surface. Without an AUMID + Start Menu
    // shortcut, Win11 media card shows「未知应用」instead of「泛音」.
    // 歌词进程是无任务栏的悬浮窗，不需要 AUMID。
    ApplyAppUserModelId();
    RemoveLegacyShortcut();
    EnsureStartMenuShortcut();
  }

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  if (lyric_process) {
    // 歌词窗：默认 720x88，不居中；Dart 会 setFrameless/setSize/setPosition，
    // 首帧前保持隐藏（见 FlutterWindow::OnCreate）。
    Win32Window::Size size(720, 88);
    Win32Window::Point origin(80, 56);
    if (!window.Create(L"overtone-lyric", origin, size)) {
      return EXIT_FAILURE;
    }
    window.SetQuitOnClose(true);
    ::MSG msg;
    while (::GetMessage(&msg, nullptr, 0, 0)) {
      ::TranslateMessage(&msg);
      ::DispatchMessage(&msg);
    }
    ::CoUninitialize();
    return EXIT_SUCCESS;
  }

  // Default window size in logical pixels. Create scales by monitor DPI and
  // clamps to the work area, so a high-DPI / small screen opens smaller.
  Win32Window::Size size(1280, 960);
  Win32Window::Point origin(0, 0);
  if (!window.Create(L"泛音", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  // Center on the monitor work area before the window is shown.
  if (HWND hwnd = window.GetHandle()) {
    HMONITOR monitor = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
    MONITORINFO info{sizeof(info)};
    RECT window_rect{};
    if (GetMonitorInfoW(monitor, &info) && GetWindowRect(hwnd, &window_rect)) {
      const int window_width = window_rect.right - window_rect.left;
      const int window_height = window_rect.bottom - window_rect.top;
      const int work_width = info.rcWork.right - info.rcWork.left;
      const int work_height = info.rcWork.bottom - info.rcWork.top;
      const int x = info.rcWork.left + (work_width - window_width) / 2;
      const int y = info.rcWork.top + (work_height - window_height) / 2;
      SetWindowPos(hwnd, nullptr, x, y, 0, 0,
                   SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
    }
  }

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  if (single_instance_mutex != nullptr) {
    ::ReleaseMutex(single_instance_mutex);
    ::CloseHandle(single_instance_mutex);
  }
  ::CoUninitialize();
  return EXIT_SUCCESS;
}
