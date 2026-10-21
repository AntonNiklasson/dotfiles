import {
  createEditToolDefinition,
  renderDiff,
  type ExtensionAPI,
  type EditToolDetails,
} from "@earendil-works/pi-coding-agent";
import { Container, Text } from "@earendil-works/pi-tui";
import { toolRow } from "./lib/tool-row.js";

/**
 * Compact rendering for the edit tool. Collapsed shows only a header row with
 * the path and diff stats; ctrl+e / click expands to the full diff.
 */
export default function (pi: ExtensionAPI) {
  const original = createEditToolDefinition(process.cwd());

  pi.registerTool({
    ...original,
    renderCall(args, theme, context) {
      const path = String(args.path ?? args.file_path ?? "");
      const text =
        theme.fg("toolTitle", theme.bold("edit ")) + theme.fg("accent", path);
      return toolRow(new Text(text, 0, 0), theme, context);
    },
    renderResult(result, { isPartial, expanded }, theme, context) {
      const container = new Container();

      if (isPartial) {
        return toolRow(
          new Container().addChild(new Text(theme.fg("warning", "editing…"), 0, 0)),
          theme,
          context,
        );
      }

      const details = result.details as EditToolDetails | undefined;
      const firstError = result.content
        .filter((c): c is { type: "text"; text: string } => c.type === "text")
        .map((c) => c.text)
        .join("\n")
        .split("\n")[0];

      let header = "";
      if (context.isError) {
        header = theme.fg("error", firstError || "edit failed");
      } else {
        let additions = 0;
        let removals = 0;
        for (const line of (details?.diff ?? "").split("\n")) {
          if (line.startsWith("+") && !line.startsWith("+++")) additions++;
          if (line.startsWith("-") && !line.startsWith("---")) removals++;
        }
        header =
          theme.fg("success", `+${additions}`) +
          theme.fg("dim", " / ") +
          theme.fg("error", `-${removals}`);
      }

      container.addChild(new Text(header, context.outputPad, 0));

      if (expanded && details?.diff) {
        container.addChild(
          new Text(renderDiff(details.diff), context.outputPad + 2, 0),
        );
      }

      return container;
    },
  });
}
