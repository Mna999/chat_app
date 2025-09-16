import 'package:flutter/material.dart';

const double BUBBLE_RADIUS = 16.0;

class BubbleNormal extends StatelessWidget {
  final double bubbleRadius;
  final bool isSender;
  final Color color;
  final Widget child; 
  final Widget? time;
  final bool tail;
  final bool sent;
  final bool delivered;
  final bool seen;
  final TextStyle timeTextStyle;
  final BoxConstraints? constraints;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const BubbleNormal({
    Key? key,
    required this.child, 
    this.time,
    this.constraints,
    this.margin = EdgeInsets.zero,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    this.bubbleRadius = BUBBLE_RADIUS,
    this.isSender = true,
    this.color = Colors.white70,
    this.tail = true,
    this.sent = false,
    this.delivered = false,
    this.seen = false,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.leading,
    this.trailing,
    this.timeTextStyle = const TextStyle(
      color: Colors.black54,
      fontSize: 11,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool stateTick = false;
    Icon? stateIcon;
    if (sent) {
      stateTick = true;
      stateIcon = const Icon(Icons.done, size: 18, color: Color(0xFF97AD8E));
    }
    if (delivered) {
      stateTick = true;
      stateIcon =
          const Icon(Icons.done_all, size: 18, color: Color(0xFF97AD8E));
    }
    if (seen) {
      stateTick = true;
      stateIcon =
          const Icon(Icons.done_all, size: 18, color: Color(0xFF92DEDA));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color timeColor;
    if (isSender) {
      timeColor = Colors.white.withOpacity(0.8);
    } else {
      final bubbleLuminance = color.computeLuminance();
      if (isDarkMode) {
        timeColor = Colors.white.withOpacity(0.7);
      } else {
        timeColor = bubbleLuminance < 0.5
            ? Colors.white.withOpacity(0.8)
            : Colors.black.withOpacity(0.6);
      }
    }

    TextStyle dynamicTimeStyle = timeTextStyle.copyWith(color: timeColor);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        if (!isSender) leading ?? const SizedBox(width: 8),
        if (isSender) const Spacer(),
        Container(
          color: Colors.transparent,
          constraints: constraints ??
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .8),
          margin: margin,
          padding: padding,
          child: GestureDetector(
            onTap: onTap,
            onDoubleTap: onDoubleTap,
            onLongPress: onLongPress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(bubbleRadius),
                  topRight: Radius.circular(bubbleRadius),
                  bottomLeft: Radius.circular(
                      tail ? (isSender ? bubbleRadius : 0) : BUBBLE_RADIUS),
                  bottomRight: Radius.circular(
                      tail ? (isSender ? 0 : bubbleRadius) : BUBBLE_RADIUS),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      12,
                      6,
                      (isSender && (stateTick || time != null))
                          ? 50
                          : (!isSender && time != null)
                              ? 50
                              : 12,
                      6,
                    ),
                    child: child, // <-- render whatever widget passed
                  ),
                  if (time != null || (stateTick && isSender))
                    Positioned(
                      bottom: 4,
                      right: 6,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (time != null)
                            DefaultTextStyle.merge(
                              style: dynamicTimeStyle,
                              child: time!,
                            ),
                          if (stateIcon != null && stateTick && isSender) ...[
                            const SizedBox(width: 4),
                            stateIcon,
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (!isSender) const Spacer(),
        if (isSender && trailing != null) trailing!,
      ],
    );
  }
}
