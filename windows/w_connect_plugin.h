#ifndef FLUTTER_PLUGIN_W_CONNECT_PLUGIN_H_
#define FLUTTER_PLUGIN_W_CONNECT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace w_connect {

class WConnectPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WConnectPlugin();

  virtual ~WConnectPlugin();

  // Disallow copy and assign.
  WConnectPlugin(const WConnectPlugin&) = delete;
  WConnectPlugin& operator=(const WConnectPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace w_connect

#endif  // FLUTTER_PLUGIN_W_CONNECT_PLUGIN_H_
