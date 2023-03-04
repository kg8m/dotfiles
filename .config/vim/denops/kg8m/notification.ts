import type { LogLevel as CustomLoggerLogLevel } from "./logger.ts";
import { NamespacedLogger } from "./logger.ts";

export async function notify(
  { title, body, stay = false, level = "info" }: {
    title: string;
    body: string;
    stay?: boolean;
    level?: CustomLoggerLogLevel;
  },
): Promise<void> {
  const commandArgs = ["--title", title];

  if (!stay) {
    commandArgs.push("--nostay");
  }

  new NamespacedLogger(title).add(level, body);
  await new Deno.Command("notify", { args: commandArgs }).output();
}
