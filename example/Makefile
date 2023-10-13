dev:
	flutter run -d web-server --web-hostname 0.0.0.0 --web-port=9090 --release

native-rs:
	flutter_rust_bridge_codegen -r native/src/api.rs -d lib/bridge_generated.dart -c ios/Runner/bridge_generated.h -e macos/Runner/ --wasm --dart-decl-output ./lib/bridge_definitions.dart