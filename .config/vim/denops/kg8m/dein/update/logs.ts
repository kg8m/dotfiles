import type { Denops } from "https://deno.land/x/denops_std@v4.0.0/mod.ts";
import { batch } from "https://deno.land/x/denops_std@v4.0.0/batch/mod.ts";
import * as vimFuncs from "https://deno.land/x/denops_std@v4.0.0/function/mod.ts";
import * as vimOptions from "https://deno.land/x/denops_std@v4.0.0/option/mod.ts";
import { assertLike } from "https://deno.land/x/unknownutil@v2.1.0/mod.ts";
import { benchmarkOnce } from "../../benchmark.ts";
import { notify } from "../../notification.ts";

type Log = string;
type Logs = Log[];
type Progress = string;

const LOG_TEMPLATE: Log = "";
const LOGS_TEMPLATE: Logs = [];
const PROGRESS_TEMPLATE: Progress = "";

interface CheckOptions {
  retryCount: number;
  prevProgress: Progress;
}

interface CheckResult {
  status: "running" | "finished" | "error";
  logs: Logs;
  options: CheckOptions;
}

const MAX_CHECK_RETRY = 60 * 5;
const DURATION_THRESHOLD_SECONDS = 30;
const LOG_SKIP_PATTERN = new RegExp(
  [
    /^$/,
    /^ +\w+\.\.\w+ +[^ ]+ +-> origin\/[^ ]+$/,
    /^ - \[deleted\] +[^ ]+ +-> [^ ]+$/,
    /^ [^ ]+ +\| +\d+ [-+]+$/,
    /^ \* \[(new branch|new tag)\] /,
    /^Already up to date\.$/,
    /^Applied autostash\.$/,
    /^Created autostash: \w+$/,
    /^Fast-forward$/,
    /^Fetching submodule [^ ]+$/,
    /^From github\.com:/,
    /^From https:\/\//,
    /^Submodule path '[^ ]': checked out '\w+'$/,
    /^Updating \w+\.\.\w+$/,
    /^Your configuration specifies to merge with the ref '[^ ]+'$/,
    /^[^ ]+: pushed_time=\d+, repo_time=\d+, rollback_time=\d+$/,
    /^[^ ]+: remote=\w*, local=\w+$/,
    /^\( *\d+\/\d+\) \[[-+]+\] ([^ ]+|compare plugin|send query)$/,
    /^\( *\d+\/\d+\) \|[^ ]+ *\| Same revision$/,
    /^from the remote, but no such ref was fetched\.$/,
    /^origin\/HEAD set to [^ ]+$/,
  ].map((regexp) => regexp.source).join("|"),
);

export async function show(denops: Denops): Promise<void> {
  const NOTIFICATION_TITLE = "Updating Vim Plugins";

  try {
    const elapsedTime = await benchmarkOnce(() => {
      return new Promise((resolve, reject) => {
        scheduleToRun({ retryCount: 0, prevProgress: "" });

        function scheduleToRun(options: CheckOptions): void {
          setTimeout(async () => {
            const checkResult = await checkProgress(denops, options);
            await writeLogs(denops, checkResult.logs);

            switch (checkResult.status) {
              case "running":
                return scheduleToRun(checkResult.options);
              case "finished":
                return resolve();
              case "error":
                return reject();
              default: {
                const unknownStatus: never = checkResult.status;
                throw new Error("Unknown status:", unknownStatus);
              }
            }
          }, 1000);
        }
      });
    });

    const shouldStay = elapsedTime > DURATION_THRESHOLD_SECONDS * 1000;
    await notify({
      title: NOTIFICATION_TITLE,
      body: "Finished.",
      stay: shouldStay,
    });
  } catch {
    await notify({
      title: NOTIFICATION_TITLE,
      body: "Something is wrong.",
      stay: true,
      level: "error",
    });
  }
}

// cf. .config/vim/syntax/dein_update_logs.vim
const BUFNAME = "kg8m://plugin/update/logs";
const FILETYPE = "dein_update_logs";
const SYNTAX_NAME = FILETYPE;

async function writeLogs(denops: Denops, logs: Logs): Promise<void> {
  let bufnr = await vimFuncs.bufnr(denops, BUFNAME);

  if (bufnr === -1 || bufnr === undefined) {
    await denops.cmd(`noswapfile edit ${BUFNAME}`);
    bufnr = await vimFuncs.bufnr(denops, "%");

    await batch(denops, async (denops) => {
      await vimOptions.filetype.set(denops, FILETYPE);
      await vimFuncs.setbufvar(denops, bufnr, "&buftype", "nofile");
    });
  }

  await batch(denops, async (denops) => {
    await vimFuncs.setbufvar(denops, bufnr, "&modifiable", true);

    await vimFuncs.setbufline(denops, bufnr, 1, logs);
    await vimFuncs.deletebufline(denops, bufnr, logs.length + 1, "$");

    await vimFuncs.setbufvar(denops, bufnr, "&modifiable", false);
    await vimFuncs.setbufvar(denops, bufnr, "&modified", false);
    await vimFuncs.setbufvar(denops, bufnr, "&syntax", SYNTAX_NAME);
  });
}

async function checkProgress(
  denops: Denops,
  options: CheckOptions,
): Promise<CheckResult> {
  options = { ...options };

  const logs = filterLogs(await getLogs(denops));
  const lastLog = logs.at(-1);
  const resultBase = { logs, options };

  if (lastLog && lastLog.startsWith("Done:")) {
    return { ...resultBase, status: "finished" };
  }

  const progress = await getProgress(denops);

  if (progress === options.prevProgress) {
    options.retryCount++;

    if (options.retryCount > MAX_CHECK_RETRY) {
      return { ...resultBase, status: "error" };
    }
  } else {
    options.retryCount = 0;
  }

  options.prevProgress = progress;

  return { ...resultBase, status: "running" };
}

async function getLogs(denops: Denops): Promise<Logs> {
  return ensureLogs(
    await denops.call("dein#install#_get_log"),
  );
}

function filterLogs(logs: Logs): Logs {
  return logs.filter((log) => !LOG_SKIP_PATTERN.test(log));
}

async function getProgress(denops: Denops): Promise<Progress> {
  return ensureProgress(await denops.call("dein#install#_get_progress"));
}

function ensureLogs(maybeLogs: unknown): Logs {
  const predicate = (maybeLog: unknown): maybeLog is Log => {
    return typeof maybeLog === typeof LOG_TEMPLATE;
  };
  assertLike(LOGS_TEMPLATE, maybeLogs, predicate);
  return maybeLogs;
}

function ensureProgress(maybeProgress: unknown): Progress {
  assertLike(PROGRESS_TEMPLATE, maybeProgress);
  return maybeProgress;
}
