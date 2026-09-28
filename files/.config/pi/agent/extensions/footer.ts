import { homedir } from "node:os";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

const singleLine = (text: string) => text.replace(/[\r\n\t]/g, " ");

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, _theme, footerData) => {
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          if (width <= 0) return [];
          // Read the active theme on every render so /settings changes apply.
          const theme = ctx.ui.theme;
          const home = homedir();
          const cwd = ctx.sessionManager.getCwd();
          const path = cwd === home ? "~" : cwd.startsWith(`${home}/`) ? `~${cwd.slice(home.length)}` : cwd;
          const branch = footerData.getGitBranch();
          const name = ctx.sessionManager.getSessionName();
          const location = singleLine(`${path}${branch ? ` (${branch})` : ""}${name ? ` • ${name}` : ""}`);

          const usage = ctx.getContextUsage();
          const percent = usage?.percent;
          const capacity = usage?.contextWindow ?? ctx.model?.contextWindow;
          const capacityLabel = !capacity ? "?"
            : capacity >= 1_000_000 ? `${Number((capacity / 1_000_000).toFixed(1))}M`
            : `${Math.round(capacity / 1000)}k`;
          const tokens = usage?.tokens;
          const usedLabel = tokens == null ? "?" : `${(tokens / 1000).toFixed(1)}k`;
          const contextLabel = `context ${usedLabel} of ${capacityLabel}`;
          const contextColor = percent != null && percent > 90 ? "error" : percent != null && percent > 70 ? "warning" : "muted";
          const left = theme.fg(contextColor, contextLabel);
          const model = ctx.model;
          const right = theme.fg("muted", singleLine(`${model?.id ?? "no model"}${model?.reasoning ? ` • ${pi.getThinkingLevel()}` : ""}`));

          const lines = [truncateToWidth(theme.fg("muted", location), width)];
          if (visibleWidth(left) + 2 + visibleWidth(right) <= width) {
            lines.push(left + " ".repeat(width - visibleWidth(left) - visibleWidth(right)) + right);
          } else {
            // Stack rather than silently dropping model info in narrow panes.
            lines.push(truncateToWidth(left, width), truncateToWidth(right, width));
          }

          const statuses = [...footerData.getExtensionStatuses()]
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, text]) => singleLine(text));
          if (statuses.length) lines.push(truncateToWidth(statuses.join(" "), width));
          return lines;
        },
      };
    });
  });
}
