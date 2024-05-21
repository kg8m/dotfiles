import type { Denops } from "https://deno.land/x/denops_std@v6.5.0/mod.ts";
import { show } from "./dein/update/logs.ts";

export function main(denops: Denops): void {
  denops.dispatcher = {
    "dein:update:logs:show": async () => await show(denops),
  };
}
