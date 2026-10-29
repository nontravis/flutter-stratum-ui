// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../responsive.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Responsive<T> {


/// Create a copy of Responsive
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResponsiveCopyWith<T, Responsive<T>> get copyWith => _$ResponsiveCopyWithImpl<T, Responsive<T>>(this as Responsive<T>, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Responsive<T>;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Responsive<T>&&const DeepCollectionEquality().equals(other.base, _this.base)&&const DeepCollectionEquality().equals(other.watch, _this.watch)&&const DeepCollectionEquality().equals(other.mobile, _this.mobile)&&const DeepCollectionEquality().equals(other.tablet, _this.tablet)&&const DeepCollectionEquality().equals(other.desktop, _this.desktop)&&const DeepCollectionEquality().equals(other.bigDesktop, _this.bigDesktop));
}


@override
int get hashCode {
  final _this = this as Responsive<T>;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.base),const DeepCollectionEquality().hash(_this.watch),const DeepCollectionEquality().hash(_this.mobile),const DeepCollectionEquality().hash(_this.tablet),const DeepCollectionEquality().hash(_this.desktop),const DeepCollectionEquality().hash(_this.bigDesktop));
}

@override
String toString() {
  final _this = this as Responsive<T>;
  return 'Responsive<$T>(base: ${_this.base}, watch: ${_this.watch}, mobile: ${_this.mobile}, tablet: ${_this.tablet}, desktop: ${_this.desktop}, bigDesktop: ${_this.bigDesktop})';
}


}

/// @nodoc
abstract mixin class $ResponsiveCopyWith<T,$Res>  {
  factory $ResponsiveCopyWith(Responsive<T> value, $Res Function(Responsive<T>) _then) = _$ResponsiveCopyWithImpl;
@useResult
$Res call({
 T base, T? watch, T? mobile, T? tablet, T? desktop, T? bigDesktop
});




}
/// @nodoc
class _$ResponsiveCopyWithImpl<T,$Res>
    implements $ResponsiveCopyWith<T, $Res> {
  _$ResponsiveCopyWithImpl(this._self, this._then);

  final Responsive<T> _self;
  final $Res Function(Responsive<T>) _then;

/// Create a copy of Responsive
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? base = freezed,Object? watch = freezed,Object? mobile = freezed,Object? tablet = freezed,Object? desktop = freezed,Object? bigDesktop = freezed,}) {
  return _then(Responsive(
freezed == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as T,watch: freezed == watch ? _self.watch : watch // ignore: cast_nullable_to_non_nullable
as T?,mobile: freezed == mobile ? _self.mobile : mobile // ignore: cast_nullable_to_non_nullable
as T?,tablet: freezed == tablet ? _self.tablet : tablet // ignore: cast_nullable_to_non_nullable
as T?,desktop: freezed == desktop ? _self.desktop : desktop // ignore: cast_nullable_to_non_nullable
as T?,bigDesktop: freezed == bigDesktop ? _self.bigDesktop : bigDesktop // ignore: cast_nullable_to_non_nullable
as T?,
  ));
}

}



// dart format on
