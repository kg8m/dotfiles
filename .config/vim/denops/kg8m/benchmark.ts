type Callback = () => Promise<void>;

export async function benchmarkOnce(callback: Callback): Promise<number> {
  const startTime = new Date();

  await callback();

  const finishTime = new Date();
  return finishTime.getTime() - startTime.getTime();
}
