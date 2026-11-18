import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  Container,
  Spacer,
  sliceByColumn,
  stripTerminalSequences,
  truncateToWidth,
} from "@earendil-works/pi-tui";

export default function (pi: ExtensionAPI) {
  let restore: (() => void) | undefined;

  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setHeader((tui) => {
      // Pi 1.5 has no separate header-help/model-scope settings. Locate only
      // the startup container; leave native resource sections and chat alone.
      const findHeader = (container: Container): Container | undefined => {
        if (container.children.some((child) => "onLogoClick" in child)) return container;
        for (const child of container.children) {
          if (child instanceof Container) {
            const found = findHeader(child);
            if (found) return found;
          }
        }
      };
      const container = findHeader(tui);
      const header = container?.children.find((child) => "onLogoClick" in child);
      if (!container || !header) throw new Error("ui-plus: Pi startup header layout has changed");

      const scopeIndex = container.children.findIndex((child) =>
        stripTerminalSequences(child.render(10000).join("\n")).trimStart().startsWith("Model scope:"),
      );
      const removed = scopeIndex < 0 ? [] : container.children.splice(
        scopeIndex,
        container.children[scopeIndex + 1] instanceof Spacer ? 2 : 1,
      );
      restore = () => {
        if (removed.length) container.children.splice(scopeIndex, 0, ...removed);
        ctx.ui.setHeader(undefined);
      };

      // Reuse Pi's actual logo/version (including its terminal fallback and
      // theme handling). No setExpanded/input handler: startup help is gone.
      return {
        render(width) {
          const lines = header.render(10000);
          const logo = [(lines[0] ?? "").trimEnd()];
          if (!stripTerminalSequences(logo[0]).trimStart().startsWith("Pi ")) {
            logo.push(sliceByColumn(lines[1] ?? "", 0, 5)); // padding + four-cell logo
          }
          return logo.map((line) => truncateToWidth(line, width));
        },
        invalidate() { header.invalidate(); },
      };
    });
  });

  pi.on("session_shutdown", () => {
    restore?.();
    restore = undefined;
  });
}
