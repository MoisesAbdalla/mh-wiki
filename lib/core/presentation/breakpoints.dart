/// Layout breakpoints (research R9). Decisions are width-based, never
/// device-based (FR-019).
abstract final class Breakpoints {
  /// From this available width on, list and detail are shown side by side.
  static const double expanded = 840;

  /// Width of the list pane in the expanded layout.
  static const double listPaneWidth = 360;
}
