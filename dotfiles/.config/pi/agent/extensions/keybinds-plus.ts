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

  for (const [key, step] of [["ctrl+h", 1], ["ctrl+l", -1]] as const) {
    pi.registerShortcut(key, {
      description: step < 0 ? "Select previous model" : "Select next model",
      handler: async (ctx) => {
        const available = ctx.modelRegistry.getAvailable();
        const models = ctx.scopedModels.length > 0
          ? ctx.scopedModels.filter(({ model }) => available.some(
              (candidate) => candidate.provider === model.provider && candidate.id === model.id,
            ))
          : available.map((model) => ({ model, thinkingLevel: undefined }));
        const index = models.findIndex(({ model }) =>
          model.provider === ctx.model?.provider && model.id === ctx.model?.id,
        );
        const next = models[index === -1 ? (step > 0 ? 0 : models.length - 1) : index + step];
        if (!next) return;
        if (!(await pi.setModel(next.model))) {
          ctx.ui.notify(`No API key for ${next.model.provider}/${next.model.id}`, "warning");
          return;
        }
        if (next.thinkingLevel !== undefined) pi.setThinkingLevel(next.thinkingLevel);
        ctx.ui.notify(`Switched to ${next.model.name || next.model.id}`, "info");
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
