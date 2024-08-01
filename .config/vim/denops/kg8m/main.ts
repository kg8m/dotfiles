import type { Entrypoint } from "jsr:@denops/std@7.0.1";
import { show } from "./dein/update/logs.ts";

export const main: Entrypoint = (denops) => {
  denops.dispatcher = {
    "dein:update:logs:show": async () => await show(denops),
  };
};
