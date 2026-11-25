//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <app_links/app_links_plugin_c_api.h>
#include <connectivity_plus/connectivity_plus_windows_plugin.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <flutter_udid/flutter_udid_plugin_c_api.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <share_plus/share_plus_windows_plugin_c_api.h>
#include <webview_all_windows/webview_all_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AppLinksPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AppLinksPluginCApi"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  FlutterUdidPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterUdidPluginCApi"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  SharePlusWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SharePlusWindowsPluginCApi"));
  WebviewAllWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WebviewAllWindowsPlugin"));
}
