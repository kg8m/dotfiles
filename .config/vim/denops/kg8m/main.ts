import type { Entrypoint } from "https://deno.land/x/denops_std@v6.5.1/mod.ts";
import { show } from "./dein/update/logs.ts";

export const main: Entrypoint = (denops) => {
  denops.dispatcher = {
    "dein:update:logs:show": async () => await show(denops),
  };
};
