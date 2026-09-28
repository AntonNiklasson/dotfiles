import {
  createReadToolDefinition,
  type ExtensionAPI,
} from "@earendil-works/pi-coding-agent";
import { toolRow } from "./lib/tool-row.js";

export default function (pi: ExtensionAPI) {
  const original = createReadToolDefinition(process.cwd());
  pi.registerTool({
    ...original,
    renderShell: "self",
    renderCall(args, theme, context) {
      // The previous component is our wrapper, not the built-in Text component.
      return toolRow(original.renderCall!(args, theme, { ...context, lastComponent: undefined }), theme, context);
    },
    renderResult(result, options, theme, context) {
      return toolRow(original.renderResult!(result, options, theme, { ...context, lastComponent: undefined }), theme, context);
    },
  });
}
