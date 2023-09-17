import 'package:flutter/material.dart';
import 'package:material_table_view/src/table_view_style.dart';

double _guessScrollbarThickness(BuildContext context, bool vertical,
    ResolvedTableViewScrollbarStyle style) {
  if (!style.effectivelyEnabled) return .0;

  // TODO determining paddings for the scrollbars based on a target platform seems stupid
  switch (Theme.of(context).platform) {
    case TargetPlatform.android:
      return 4.0;
    case TargetPlatform.iOS:
      return 6.0;
    default:
      return vertical ? 14.0 : 10.0;
  }
}

class ResolvedTableViewStyle extends TableViewStyle {
  @override
  ResolvedTableViewDividersStyle get dividers =>
      super.dividers as ResolvedTableViewDividersStyle;

  @override
  ResolvedTableViewScrollbarsStyle get scrollbars =>
      super.scrollbars as ResolvedTableViewScrollbarsStyle;

  @override
  EdgeInsets get scrollPadding => super.scrollPadding!;

  ResolvedTableViewStyle({
    required ResolvedTableViewDividersStyle dividers,
    required ResolvedTableViewScrollbarsStyle scrollbars,
    required EdgeInsets scrollPadding,
  }) : super(
          dividers: dividers,
          scrollbars: scrollbars,
          scrollPadding: scrollPadding,
        );

  factory ResolvedTableViewStyle.of(
    BuildContext context, {
    required TableViewStyle? style,
    required bool sliver,
  }) {
    final base = Theme.of(context).extension<TableViewStyle>();
    final scrollbars = ResolvedTableViewScrollbarsStyle.of(
      context,
      base: base?.scrollbars,
      style: style?.scrollbars,
    );

    return ResolvedTableViewStyle(
      dividers: ResolvedTableViewDividersStyle.of(
        context,
        base: base?.dividers,
        style: style?.dividers,
      ),
      scrollbars: scrollbars,
      scrollPadding: (style?.scrollPadding ??
              base?.scrollPadding ??
              EdgeInsets.zero) +
          EdgeInsets.only(
            right: sliver // we have no way of knowing the size of a scrollbar
                ? .0 // so we just give up
                : _guessScrollbarThickness(context, true, scrollbars.vertical),
            bottom:
                _guessScrollbarThickness(context, false, scrollbars.horizontal),
          ),
    );
  }
}

class ResolvedTableViewDividersStyle extends TableViewDividersStyle {
  @override
  ResolvedTableViewHorizontalDividersStyle get horizontal =>
      super.horizontal as ResolvedTableViewHorizontalDividersStyle;

  ResolvedTableViewVerticalDividersStyle get vertical =>
      super.vertical as ResolvedTableViewVerticalDividersStyle;

  ResolvedTableViewDividersStyle({
    required ResolvedTableViewHorizontalDividersStyle horizontalDividersStyle,
    required ResolvedTableViewVerticalDividersStyle verticalDividersStyle,
  }) : super(
          horizontal: horizontalDividersStyle,
          vertical: verticalDividersStyle,
        );

  factory ResolvedTableViewDividersStyle.of(
    BuildContext context, {
    required TableViewDividersStyle? base,
    required TableViewDividersStyle? style,
  }) =>
      ResolvedTableViewDividersStyle(
        horizontalDividersStyle: ResolvedTableViewHorizontalDividersStyle.of(
          context,
          base: base?.horizontal,
          style: style?.horizontal,
        ),
        verticalDividersStyle: ResolvedTableViewVerticalDividersStyle.of(
          context,
          base: base?.vertical,
          style: style?.vertical,
        ),
      );
}

class ResolvedTableViewHorizontalDividersStyle
    extends TableViewHorizontalDividersStyle {
  @override
  ResolvedTableViewHorizontalDividerStyle get header =>
      super.header as ResolvedTableViewHorizontalDividerStyle;

  ResolvedTableViewHorizontalDividerStyle get footer =>
      super.footer as ResolvedTableViewHorizontalDividerStyle;

  ResolvedTableViewHorizontalDividersStyle({
    required ResolvedTableViewHorizontalDividerStyle headerDividerStyle,
    required ResolvedTableViewHorizontalDividerStyle footerDividerStyle,
  }) : super(
          header: headerDividerStyle,
          footer: footerDividerStyle,
        );

  factory ResolvedTableViewHorizontalDividersStyle.of(
    BuildContext context, {
    required TableViewHorizontalDividersStyle? base,
    required TableViewHorizontalDividersStyle? style,
  }) =>
      ResolvedTableViewHorizontalDividersStyle(
        headerDividerStyle: ResolvedTableViewHorizontalDividerStyle.of(
          context,
          base: base?.header,
          style: style?.header,
        ),
        footerDividerStyle: ResolvedTableViewHorizontalDividerStyle.of(
          context,
          base: base?.footer,
          style: style?.footer,
        ),
      );
}

class ResolvedTableViewHorizontalDividerStyle
    extends TableViewHorizontalDividerStyle {
  @override
  Color get color => super.color!;

  @override
  double get thickness => super.thickness!;

  ResolvedTableViewHorizontalDividerStyle({
    required Color color,
    required double thickness,
  }) : super(
          color: color,
          thickness: thickness,
        );

  factory ResolvedTableViewHorizontalDividerStyle.of(
    BuildContext context, {
    required TableViewHorizontalDividerStyle? base,
    required TableViewHorizontalDividerStyle? style,
  }) {
    late final borderStyle = Divider.createBorderSide(context);
    return ResolvedTableViewHorizontalDividerStyle(
      color: style?.color ?? base?.color ?? borderStyle.color,
      thickness: style?.thickness ?? base?.thickness ?? borderStyle.width,
    );
  }
}

class ResolvedTableViewVerticalDividersStyle
    extends TableViewVerticalDividersStyle {
  @override
  ResolvedTableViewVerticalDividerStyle get leading =>
      super.leading as ResolvedTableViewVerticalDividerStyle;

  ResolvedTableViewVerticalDividerStyle get trailing =>
      super.trailing as ResolvedTableViewVerticalDividerStyle;

  ResolvedTableViewVerticalDividersStyle({
    required ResolvedTableViewVerticalDividerStyle leadingDividerStyle,
    required ResolvedTableViewVerticalDividerStyle trailingDividerStyle,
  }) : super(
          leading: leadingDividerStyle,
          trailing: trailingDividerStyle,
        );

  factory ResolvedTableViewVerticalDividersStyle.of(
    BuildContext context, {
    required TableViewVerticalDividersStyle? base,
    required TableViewVerticalDividersStyle? style,
  }) =>
      ResolvedTableViewVerticalDividersStyle(
        leadingDividerStyle: ResolvedTableViewVerticalDividerStyle.of(
          context,
          base: base?.leading,
          style: style?.leading,
        ),
        trailingDividerStyle: ResolvedTableViewVerticalDividerStyle.of(
          context,
          base: base?.trailing,
          style: style?.trailing,
        ),
      );
}

class ResolvedTableViewVerticalDividerStyle
    extends TableViewVerticalDividerStyle {
  @override
  Color get color => super.color!;

  @override
  double get thickness => super.thickness!;

  @override
  int get wigglesPerRow => super.wigglesPerRow!;

  @override
  double get wiggleOffset => super.wiggleOffset!;

  ResolvedTableViewVerticalDividerStyle({
    required Color color,
    required double thickness,
    required int wigglesPerRow,
    required double wiggleOffset,
  }) : super(
          color: color,
          wigglesPerRow: wigglesPerRow,
          thickness: thickness,
          wiggleOffset: wiggleOffset,
        );

  factory ResolvedTableViewVerticalDividerStyle.of(
    BuildContext context, {
    required TableViewVerticalDividerStyle? base,
    required TableViewVerticalDividerStyle? style,
  }) {
    late final borderStyle = Divider.createBorderSide(context);
    return ResolvedTableViewVerticalDividerStyle(
      color: style?.color ?? base?.color ?? borderStyle.color,
      thickness: style?.thickness ?? base?.thickness ?? borderStyle.width,
      wigglesPerRow: style?.wigglesPerRow ?? base?.wigglesPerRow ?? 1,
      wiggleOffset: style?.wiggleOffset ?? base?.wiggleOffset ?? 16.0,
    );
  }
}

class ResolvedTableViewScrollbarsStyle extends TableViewScrollbarsStyle {
  @override
  ResolvedTableViewScrollbarStyle get horizontal =>
      super.horizontal as ResolvedTableViewScrollbarStyle;

  @override
  ResolvedTableViewScrollbarStyle get vertical =>
      super.vertical as ResolvedTableViewScrollbarStyle;

  ResolvedTableViewScrollbarsStyle({
    required ResolvedTableViewScrollbarStyle horizontal,
    required ResolvedTableViewScrollbarStyle vertical,
  }) : super(
          horizontal: horizontal,
          vertical: vertical,
        );

  factory ResolvedTableViewScrollbarsStyle.of(
    BuildContext context, {
    required TableViewScrollbarsStyle? base,
    required TableViewScrollbarsStyle? style,
  }) =>
      ResolvedTableViewScrollbarsStyle(
        horizontal: ResolvedTableViewScrollbarStyle.of(
          context,
          base: base?.horizontal,
          style: style?.horizontal,
        ),
        vertical: ResolvedTableViewScrollbarStyle.of(
          context,
          base: base?.vertical,
          style: style?.vertical,
        ),
      );
}

bool _resolveEnabled(BuildContext context, TableViewScrollbarEnabled enabled) {
  switch (enabled) {
    case TableViewScrollbarEnabled.always:
      return true;
    case TableViewScrollbarEnabled.auto:
      return [
        TargetPlatform.linux,
        TargetPlatform.macOS,
        TargetPlatform.windows
      ].contains(Theme.of(context).platform);
    case TableViewScrollbarEnabled.never:
      return false;
  }
}

class ResolvedTableViewScrollbarStyle extends TableViewScrollbarStyle {
  final bool effectivelyEnabled;

  @override
  TableViewScrollbarEnabled get enabled => super.enabled!;

  @override
  bool get thumbVisibility => super.thumbVisibility!;

  @override
  bool get trackVisibility => super.trackVisibility!;

  @override
  bool get interactive => super.interactive!;

  const ResolvedTableViewScrollbarStyle({
    required this.effectivelyEnabled,
    required TableViewScrollbarEnabled enabled,
    required bool thumbVisibility,
    required bool trackVisibility,
    super.thickness,
    super.radius,
    required bool interactive,
  }) : super(
          enabled: enabled,
          thumbVisibility: thumbVisibility,
          trackVisibility: trackVisibility,
          interactive: interactive,
        );

  factory ResolvedTableViewScrollbarStyle.of(
    BuildContext context, {
    TableViewScrollbarStyle? base,
    TableViewScrollbarStyle? style,
  }) {
    final enabled =
        style?.enabled ?? base?.enabled ?? TableViewScrollbarEnabled.always;
    return ResolvedTableViewScrollbarStyle(
      enabled: enabled,
      effectivelyEnabled: _resolveEnabled(context, enabled),
      thumbVisibility: style?.thumbVisibility ?? base?.thumbVisibility ?? true,
      trackVisibility: style?.trackVisibility ?? base?.trackVisibility ?? true,
      thickness: style?.thickness ?? base?.thickness,
      radius: style?.radius ?? base?.radius,
      interactive: style?.interactive ?? base?.interactive ?? true,
    );
  }
}
