export 'package:flutter_stratum_ui/src/components/common/web_view/platform/platform_web_view_stub.dart'
    if (dart.library.js_interop) 'package:flutter_stratum_ui/src/components/common/web_view/platform/platform_web_view_web.dart'
    if (dart.library.io) 'package:flutter_stratum_ui/src/components/common/web_view/platform/platform_web_view_io.dart';
