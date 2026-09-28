import type { Theme, ToolRenderContext } from "@earendil-works/pi-coding-agent";
import { Box, truncateToWidth, type Component } from "@earendil-works/pi-tui";

/** Horizontal padding and themed background, without vertical padding. */
export function toolRow(component: Component, theme: Theme, context: ToolRenderContext): Component {
  const background = context.isError ? "toolErrorBg" : context.isPartial ? "toolPendingBg" : "toolSuccessBg";
  const box = new Box(1, 0, (line) => theme.bg(background, line));
  box.addChild(component);
  return {
    invalidate: () => box.invalidate(),
    render: (width) => width > 0 ? box.render(width).map((line) => truncateToWidth(line, width, "")) : [],
  };
}
