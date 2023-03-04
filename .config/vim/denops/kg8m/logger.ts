export type LogLevel = keyof NamespacedLogger & keyof Console;
type LogData = Parameters<NamespacedLogger[LogLevel]>;

export class NamespacedLogger {
  #prefix: string;

  constructor(namespace: string) {
    this.#prefix = `${namespace}:`;
  }

  add(level: LogLevel, ...data: LogData): void {
    this[level](...data);
  }

  info(...data: Parameters<Console["info"]>): void {
    console.info(this.#prefix, ...data);
  }

  warn(...data: Parameters<Console["warn"]>): void {
    console.warn(this.#prefix, ...data);
  }

  error(...data: Parameters<Console["error"]>): void {
    console.error(this.#prefix, ...data);
  }
}
