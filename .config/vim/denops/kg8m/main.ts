import type { Entrypoint } from "jsr:@denops/std@^8.0.0";
import { show } from "./dein/update/logs.ts";

export const main: Entrypoint = (denops) => {
  denops.dispatcher = {
    "dein:update:logs:show": async () => await show(denops),
  };
};
