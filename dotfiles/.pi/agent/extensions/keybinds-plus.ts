import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { getSupportedThinkingLevels } from "@earendil-works/pi-ai/compat";
import { matchesKey } from "@earendil-works/pi-tui";

export default function (pi: ExtensionAPI) {
  for (const [key, step] of [["ctrl+j", -1], ["ctrl+k", 1]] as const) {
    pi.registerShortcut(key, {
      description: step < 0 ? "Decrease thinking level" : "Increase thinking level",
      handler: async (ctx) => {
        if (!ctx.model) return;
        const levels = getSupportedThinkingLevels(ctx.model);
        const next = levels[levels.indexOf(pi.getThinkingLevel()) + step];
        if (next !== undefined) pi.setThinkingLevel(next);
      },
    });
  }

  pi.on("session_start", (_event, ctx) => {
    if (!ctx.hasUI) return;
    ctx.ui.onTerminalInput((data) => {
      // Legacy terminals send the same byte for Enter and Ctrl+M. Never quit on it.
      if (data === "\r" || matchesKey(data, "enter") || !matchesKey(data, "ctrl+m")) return;
      if (!ctx.isIdle()) ctx.abort();
      ctx.shutdown();
      return { consume: true };
    });
  });
}
