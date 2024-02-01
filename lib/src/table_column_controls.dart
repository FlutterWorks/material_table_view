import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/src/table_column.dart';
import 'package:material_table_view/src/table_layout.dart';
import 'package:material_table_view/src/table_view_horizontal_scroll_controller_provider.dart';

PreferredSizeWidget _buildAnimatedIconButton(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  IconData icon,
) {
  final density = Theme.of(context).visualDensity;

  final border = Divider.createBorderSide(context);

  animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

  final size = Size(
    48 + 8 * density.horizontal,
    48 + 8 * density.vertical,
  );

  return PreferredSize(
    preferredSize: size,
    child: Center(
      child: ListenableBuilder(
        listenable: animation,
        builder: (context, _) => SizedBox(
          width: animation.value * size.width,
          height: animation.value * size.height,
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            type: MaterialType.button,
            shape: CircleBorder(side: border),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 8 + density.vertical,
                horizontal: 8 + density.horizontal,
              ),
              child: Center(
                child: FittedBox(
                  child: Icon(
                    icon,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

PreferredSizeWidget _defaultResizeHandleBuilder(
  BuildContext context,
  bool leading,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
) =>
    _buildAnimatedIconButton(
      context,
      animation,
      secondaryAnimation,
      leading ? Icons.switch_right : Icons.switch_left,
    );

PreferredSizeWidget _defaultDragHandleBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
) =>
    _buildAnimatedIconButton(
      context,
      animation,
      secondaryAnimation,
      Icons.drag_indicator,
    );

typedef void ColumnResizeCallback(int index, TableColumn newColumn);

typedef void ColumnMoveCallback(int oldIndex, int newIndex);

typedef void ColumnTranslateCallback(int index, TableColumn newColumn);

class TableColumnControls extends StatefulWidget {
  final List<TableColumn> columns;

  final ColumnResizeCallback? onColumnResize;

  final ColumnMoveCallback? onColumnMove;

  final ColumnTranslateCallback? onColumnTranslate;

  final Widget child;

  final Color? barrierColor;

  final PreferredSizeWidget Function(
    BuildContext context,
    bool leading,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  )? resizeHandleBuilder;

  final PreferredSizeWidget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  )? dragHandleBuilder;

  TableColumnControls({
    super.key,
    required this.columns,
    required this.child,
    this.onColumnResize,
    this.onColumnMove,
    this.onColumnTranslate,
    this.barrierColor,
    this.resizeHandleBuilder = _defaultResizeHandleBuilder,
    this.dragHandleBuilder = _defaultDragHandleBuilder,
  });

  @override
  State<StatefulWidget> createState() => _TableColumnControlsState();

  static TableColumnControlsInterface of(BuildContext context) {
    final state = context.findAncestorStateOfType<_TableColumnControlsState>();
    assert(
      state != null,
      'Could not find TableColumnControls widget ancestor.'
      ' Make sure you used the right BuildContext and your TableView'
      ' is directly or indirectly contained within TableColumnControls widget.',
    );

    return TableColumnControlsInterface._(context, state!);
  }
}

class TableColumnControlsInterface {
  final BuildContext context;
  final _TableColumnControlsState _state;

  TableColumnControlsInterface._(
    this.context,
    this._state,
  );

  FutureOr<void> invoke(int columnIndex) => _state.invoke(context, columnIndex);
}

class _TableColumnControlsState extends State<TableColumnControls> {
  @override
  Widget build(BuildContext context) => Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => widget.child,
        ),
      );

  FutureOr<void> invoke(BuildContext context, int columnIndex) async {
    final tableContentLayoutState =
        context.findAncestorStateOfType<TableContentLayoutState>();
    if (tableContentLayoutState == null) return;

    final RenderBox ro;
    {
      final obj = context.findRenderObject();
      assert(obj is RenderBox);
      ro = obj as RenderBox;
    }

    final ScrollController horizontalScrollController;
    {
      final state = context.findAncestorStateOfType<
          TableViewHorizontalScrollControllerProvider>();
      assert(state != null, 'No TableView ancestor found');
      horizontalScrollController = state!.horizontalScrollController;
    }

    await Navigator.of(context).push(
      _ControlsPopupRoute(
        builder: (context, animation, secondaryAnimation) => _Widget(
          barrierColor: widget.barrierColor,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          horizontalScrollController: horizontalScrollController,
          tableColumnControlsRenderObject:
              this.context.findRenderObject() as RenderBox,
          tableContentLayoutState: tableContentLayoutState,
          tableColumnControls: widget,
          cellRenderObject: ro,
          columnIndex: columnIndex,
        ),
      ),
    );
  }
}

class _ControlsPopupRoute extends ModalRoute<void> {
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) builder;

  _ControlsPopupRoute({
    required this.builder,
  });

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Stack(
        children: [
          // this cancels pops the column controls out
          // as soon as the user tries to scroll the table
          // rather than requiring a full distinguished tap
          GestureDetector(
            onTapDown: (details) => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          builder(
            context,
            animation,
            secondaryAnimation,
          ),
        ],
      );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;
}

class _Widget extends StatefulWidget {
  final Color? barrierColor;
  final Animation<double> animation, secondaryAnimation;
  final ScrollController horizontalScrollController;
  final TableColumnControls tableColumnControls;
  final RenderBox tableColumnControlsRenderObject;
  final TableContentLayoutState tableContentLayoutState;
  final RenderBox cellRenderObject;
  final int columnIndex;

  const _Widget({
    required this.barrierColor,
    required this.animation,
    required this.secondaryAnimation,
    required this.horizontalScrollController,
    required this.tableColumnControls,
    required this.tableColumnControlsRenderObject,
    required this.tableContentLayoutState,
    required this.cellRenderObject,
    required this.columnIndex,
  });

  @override
  State<_Widget> createState() => _WidgetState();
}

class _WidgetState extends State<_Widget>
    with TickerProviderStateMixin<_Widget> {
  final clearBarrierCounter = ValueNotifier<int>(0);

  late double width;
  late double minColumnWidth;
  bool popped = false;

  late int columnIndex;
  late double dragValue;
  late List<int> movingColumnsIndices;
  late int movingColumnsTargetIndex;

  double leadingResizeHandleCorrection = .0,
      trailingResizeHandleCorrection = .0,
      moveHandleCorrection = .0;

  ScrollHoldController? scrollHold;

  @override
  void initState() {
    super.initState();

    columnIndex = widget.columnIndex;
    widget.tableContentLayoutState.addListener(_parentDataChanged);
    widget.horizontalScrollController.addListener(_horizontalScrollChanged);
  }

  @override
  void didUpdateWidget(covariant _Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tableContentLayoutState != widget.tableContentLayoutState) {
      oldWidget.tableContentLayoutState.removeListener(_parentDataChanged);
      widget.tableContentLayoutState.addListener(_parentDataChanged);
    }

    if (oldWidget.horizontalScrollController !=
        oldWidget.horizontalScrollController) {
      oldWidget.horizontalScrollController
          .removeListener(_horizontalScrollChanged);
      oldWidget.horizontalScrollController
          .addListener(_horizontalScrollChanged);
    }
  }

  @override
  void dispose() {
    widget.tableContentLayoutState.removeListener(_parentDataChanged);
    widget.horizontalScrollController.removeListener(_horizontalScrollChanged);
    scrollHold?.cancel();

    super.dispose();
  }

  void _horizontalScrollChanged() => setState(() {});

  void _parentDataChanged() =>
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) setState(() {});
      });

  void abort() {
    if (!popped) {
      popped = true;
      SchedulerBinding.instance
          .addPostFrameCallback((timeStamp) => Navigator.pop(context));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.cellRenderObject.attached ||
        !widget.tableColumnControlsRenderObject.attached ||
        !widget.tableContentLayoutState.mounted) {
      abort();

      return SizedBox();
    }

    final leadingResizeHandleCorrection = this.leadingResizeHandleCorrection;
    final trailingResizeHandleCorrection = this.trailingResizeHandleCorrection;
    final moveHandleCorrection = this.moveHandleCorrection;

    this.leadingResizeHandleCorrection = .0;
    this.trailingResizeHandleCorrection = .0;
    this.moveHandleCorrection = .0;

    final leadingResizeHandle = columnIndex == 0
        ? null
        : widget.tableColumnControls.resizeHandleBuilder
            ?.call(context, true, widget.animation, widget.secondaryAnimation);

    final trailingResizeHandle = columnIndex + 1 ==
            widget.tableColumnControls.columns.length
        ? null
        : widget.tableColumnControls.resizeHandleBuilder
            ?.call(context, false, widget.animation, widget.secondaryAnimation);

    final dragHandle = widget.tableColumnControls.dragHandleBuilder
        ?.call(context, widget.animation, widget.secondaryAnimation);

    final offset = widget.tableColumnControlsRenderObject
        .globalToLocal(widget.cellRenderObject.localToGlobal(Offset.zero));

    minColumnWidth = (dragHandle?.preferredSize.width ?? .0) +
        (((leadingResizeHandle?.preferredSize.width ?? .0) +
                (trailingResizeHandle?.preferredSize.height ?? .0))) /
            2;

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          if (widget.barrierColor != null)
            IgnorePointer(
              child: FadeTransition(
                opacity: widget.animation,
                child: ValueListenableBuilder(
                  valueListenable: clearBarrierCounter,
                  builder: (context, clearBarrierCounter, _) => SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: clearBarrierCounter == 0
                          ? ColoredBox(
                              color: widget.barrierColor!,
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          if (widget.tableColumnControls.onColumnResize != null &&
              leadingResizeHandle != null)
            Positioned(
              left: offset.dx +
                  leadingResizeHandleCorrection -
                  leadingResizeHandle.preferredSize.width / 2,
              top: offset.dy +
                  widget.cellRenderObject.size.height -
                  leadingResizeHandle.preferredSize.height / 2,
              width: leadingResizeHandle.preferredSize.width,
              height: leadingResizeHandle.preferredSize.height,
              child: GestureDetector(
                onHorizontalDragStart: _resizeStart,
                onHorizontalDragUpdate: _resizeUpdateLeading,
                onHorizontalDragEnd: _resizeEnd,
                child: leadingResizeHandle,
              ),
            ),
          if (widget.tableColumnControls.onColumnMove != null &&
              dragHandle != null)
            Positioned(
              left: moveHandleCorrection +
                  offset.dx +
                  widget.cellRenderObject.size.width / 2 -
                  dragHandle.preferredSize.width / 2,
              top: offset.dy +
                  widget.cellRenderObject.size.height -
                  dragHandle.preferredSize.height / 2,
              width: dragHandle.preferredSize.width,
              height: dragHandle.preferredSize.height,
              child: GestureDetector(
                onHorizontalDragStart: _dragStart,
                onHorizontalDragUpdate: _dragUpdate,
                onHorizontalDragEnd: _dragEnd,
                child: dragHandle,
              ),
            ),
          if (widget.tableColumnControls.onColumnResize != null &&
              trailingResizeHandle != null)
            Positioned(
              left: offset.dx +
                  trailingResizeHandleCorrection +
                  widget.cellRenderObject.size.width -
                  trailingResizeHandle.preferredSize.width / 2,
              top: offset.dy +
                  widget.cellRenderObject.size.height -
                  trailingResizeHandle.preferredSize.height / 2,
              width: trailingResizeHandle.preferredSize.width,
              height: trailingResizeHandle.preferredSize.height,
              child: GestureDetector(
                onHorizontalDragStart: _resizeStart,
                onHorizontalDragUpdate: _resizeUpdateTrailing,
                onHorizontalDragEnd: _resizeEnd,
                child: trailingResizeHandle,
              ),
            ),
        ],
      ),
    );
  }

  void _resizeStart(DragStartDetails details) {
    width = widget.tableColumnControls.columns[columnIndex].width;
    scrollHold = widget.horizontalScrollController.position.hold(() {});
    clearBarrierCounter.value++;
  }

  void _resizeUpdateLeading(DragUpdateDetails details) {
    final delta = _resizeUpdate(-details.delta.dx);

    leadingResizeHandleCorrection -= delta;
    moveHandleCorrection -= delta / 2;

    final scrollPosition = widget.horizontalScrollController.position;
    scrollPosition.jumpTo(scrollPosition.pixels + delta);

    scrollHold?.cancel();
    scrollHold = widget.horizontalScrollController.position.hold(() {});
  }

  void _resizeUpdateTrailing(DragUpdateDetails details) {
    final delta = _resizeUpdate(details.delta.dx);

    trailingResizeHandleCorrection += delta;
    moveHandleCorrection += delta / 2;
  }

  double _resizeUpdate(double delta) {
    final width = this.width + delta;
    if (width < minColumnWidth) {
      this.width = minColumnWidth;
      delta += minColumnWidth - width;
    } else {
      this.width = width;
    }

    _resizeUpdateColumns();

    return delta;
  }

  void _resizeUpdateColumns() => widget.tableColumnControls.onColumnResize!(
      columnIndex,
      widget.tableColumnControls.columns[columnIndex].copyWith(width: width));

  void _resizeEnd(DragEndDetails details) {
    scrollHold?.cancel();
    scrollHold = null;
    clearBarrierCounter.value--;
  }

  void _dragStart(DragStartDetails details) {
    dragValue = 0;

    for (final list in [
      widget.tableContentLayoutState.lastLayoutData.leadingColumnIndices,
      widget.tableContentLayoutState.lastLayoutData.scrollableColumns.indices,
      widget.tableContentLayoutState.lastLayoutData.trailingColumnIndices
    ]) {
      movingColumnsTargetIndex = list.indexOf(columnIndex);
      if (movingColumnsTargetIndex != -1) {
        movingColumnsIndices = list;
        break;
      }
    }

    assert(
      movingColumnsTargetIndex != -1,
      'Could not find the column moved in the layout.'
      ' TableColumnControls should\'ve been popped by now.',
    );

    clearBarrierCounter.value++;
  }

  void _dragUpdate(DragUpdateDetails details) {
    dragValue += details.delta.dx;

    final column = widget.tableColumnControls.columns[columnIndex];
    final width = column.width;

    if (dragValue > 0) {
      final nextIndex = movingColumnsTargetIndex + 1;
      if (nextIndex >= movingColumnsIndices.length) {
        return;
      }

      final nextWidth = widget
          .tableColumnControls.columns[movingColumnsIndices[nextIndex]].width;
      if (dragValue > nextWidth / 2) {
        _animateColumnTranslation(columnIndex, -nextWidth, column.key);
        _animateColumnTranslation(movingColumnsIndices[nextIndex], width, null);
        widget.tableColumnControls.onColumnMove!(
            columnIndex, movingColumnsIndices[nextIndex]);
        dragValue -= nextWidth;
        columnIndex++;
        movingColumnsTargetIndex++;
        return;
      }
    } else if (dragValue < 0) {
      final nextIndex = movingColumnsTargetIndex - 1;
      if (nextIndex < 0) {
        return;
      }

      final nextWidth = widget
          .tableColumnControls.columns[movingColumnsIndices[nextIndex]].width;
      if (dragValue < -nextWidth / 2) {
        _animateColumnTranslation(columnIndex, nextWidth, column.key);
        _animateColumnTranslation(
            movingColumnsIndices[nextIndex], -width, null);
        widget.tableColumnControls.onColumnMove!(
            columnIndex, movingColumnsIndices[nextIndex]);

        dragValue += nextWidth;
        columnIndex--;
        movingColumnsTargetIndex--;
        return;
      }
    }
  }

  void _dragEnd(DragEndDetails details) {
    clearBarrierCounter.value--;
  }

  void _animateColumnTranslation(
    int globalIndex,
    double translation,
    Key? correctHandles,
  ) {
    if (widget.tableColumnControls.onColumnTranslate == null) {
      return;
    }

    final ticker = <Ticker>[];

    void stop() {
      ticker[0]
        ..stop()
        ..dispose();
    }

    final Key key;
    {
      final column = widget.tableColumnControls.columns[globalIndex];
      key = column.key!;
      widget.tableColumnControls.onColumnTranslate!.call(globalIndex,
          column.copyWith(translation: column.translation + translation));
    }

    final currentGlobalIndex = <int>[globalIndex];
    final translationLeft = <double>[-translation];
    final lastElapsed = <Duration>[Duration.zero];

    const animationDuration = Duration(milliseconds: 200);

    ticker.add(createTicker((elapsed) {
      final columns = widget.tableColumnControls.columns;

      var index = currentGlobalIndex[0];
      TableColumn? column;
      if (index > columns.length ||
          (column = columns[currentGlobalIndex[0]]).key != key) {
        for (var i = 0; i < columns.length; i++) {
          if (columns[i].key == key) {
            column = columns[i];
            index = currentGlobalIndex[0] = i;
            break;
          }
        }
      }

      if (column == null) {
        stop();
        return;
      }

      void correctHandlesIfNecessary(double correction) {
        if (correctHandles != null && column!.key == correctHandles) {
          leadingResizeHandleCorrection += correction;
          trailingResizeHandleCorrection += correction;
          moveHandleCorrection += correction;
        }
      }

      if (elapsed >= animationDuration) {
        widget.tableColumnControls.onColumnTranslate?.call(
            index,
            column.copyWith(
                translation: column.translation + translationLeft[0]));
        correctHandlesIfNecessary(translationLeft[0]);
        stop();
        return;
      }

      final valuePrev =
          lastElapsed[0].inMicroseconds / animationDuration.inMicroseconds;

      final valueNext =
          elapsed.inMicroseconds / animationDuration.inMicroseconds;

      const curve = Curves.fastOutSlowIn;
      final deltaTranslation = -translation *
          (curve.transform(valueNext) - curve.transform(valuePrev));

      lastElapsed[0] = elapsed;

      translationLeft[0] -= deltaTranslation;
      widget.tableColumnControls.onColumnTranslate?.call(index,
          column.copyWith(translation: column.translation + deltaTranslation));

      correctHandlesIfNecessary(deltaTranslation);
    })
      ..start());
  }
}
