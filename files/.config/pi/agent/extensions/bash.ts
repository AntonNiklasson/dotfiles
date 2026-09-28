import {
  createBashToolDefinition,
  SettingsManager,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { Text, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { toolRow } from "./lib/tool-row.js";

interface BashRenderState {
  startedAt?: number;
  endedAt?: number;
  interval?: ReturnType<typeof setInterval>;
}

export default function (pi: ExtensionAPI) {
  const timers = new Set<ReturnType<typeof setInterval>>();
  const clearTimers = () => {
    for (const timer of timers) clearInterval(timer);
    timers.clear();
  };
  pi.on("session_start", clearTimers);
  pi.on("session_shutdown", clearTimers);

  const original = createBashToolDefinition(process.cwd());
  pi.registerTool({
    ...original,
    renderShell: "self",
    execute(toolCallId, params, signal, onUpdate, ctx) {
      // Preserve configured shell, command prefix, session environment and trust.
      const settings = SettingsManager.create(ctx.cwd, undefined, {
        projectTrusted: ctx.isProjectTrusted(),
      });
      const tool = createBashToolDefinition(ctx.cwd, {
        shellPath: settings.getShellPath(),
        commandPrefix: settings.getShellCommandPrefix(),
      });
      return tool.execute(toolCallId, params, signal, onUpdate, ctx);
    },
    renderCall(args, theme, context) {
      const state = context.state as BashRenderState;
      if (context.executionStarted) state.startedAt ??= Date.now();

      return toolRow({
        invalidate() {},
        render(width: number): string[] {
          if (width <= 0) return [];
          const command = (args.command || "…").replace(/[\x00-\x1f\x7f-\x9f]+/g, " ").replace(/ +/g, " ").trim();
          const characters = Array.from(command);
          const preview = characters.length > 50 ? `${characters.slice(0, 50).join("")}…` : command;
          const status = context.isError ? "failed" : context.isPartial ? "running" : "done";
          const elapsed = state.startedAt === undefined ? "" : ` ${Math.max(0, Math.floor(((state.endedAt ?? Date.now()) - state.startedAt) / 1000))}s`;
          const label = context.executionStarted || !context.isPartial ? `${status}${elapsed}` : "pending";
          const color = context.isError ? "error" : context.isPartial ? "muted" : "success";
          const right = theme.fg(color, label);
          const available = width - visibleWidth(right) - 2;
          if (available < 3) return [truncateToWidth(right, width)];
          const left = truncateToWidth(theme.fg("toolTitle", `$ ${preview}`), available);
          return [left + " ".repeat(width - visibleWidth(left) - visibleWidth(right)) + right];
        },
      }, theme, context);
    },
    renderResult(result, options, theme, context) {
      const state = context.state as BashRenderState;
      if (!options.isPartial || context.isError) {
        if (state.startedAt !== undefined) state.endedAt ??= Date.now();
        if (state.interval) {
          clearInterval(state.interval);
          timers.delete(state.interval);
          state.interval = undefined;
        }
      } else if (state.startedAt !== undefined && !state.interval) {
        state.interval = setInterval(() => context.invalidate(), 1000);
        state.interval.unref();
        timers.add(state.interval);
      }

      if (!options.expanded) return { render: () => [], invalidate() {} };
      const output = result.content
        .filter((content) => content.type === "text")
        .map((content) => content.text)
        .join("\n");
      return toolRow(new Text(theme.fg(context.isError ? "error" : "toolOutput", output), 0, 0), theme, context);
    },
  });
}
