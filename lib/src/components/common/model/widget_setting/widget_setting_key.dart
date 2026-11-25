import 'package:flutter_stratum_ui/src/themes/value_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/widget_setting_key.freezed.dart';

/// Which part of a widget type's settings box a value belongs to: the
/// type-wide global part, or a named id (W2, US-02 FR-01).
@valueModel
sealed class WidgetSettingKey with _$WidgetSettingKey {
  /// The type-wide part, shared by every instance of the widget type.
  const factory global() = WidgetSettingGlobal;

  /// The part shared by every instance of the widget type with this [id].
  const factory id(String id) = WidgetSettingId;
}
