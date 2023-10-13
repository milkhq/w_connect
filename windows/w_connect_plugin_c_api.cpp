#include "include/w_connect/w_connect_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "w_connect_plugin.h"

void WConnectPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  w_connect::WConnectPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
