// サムネイル画像が読み込めないとき（S3 側のファイルが無いなど）、
// data-fallback-src の画像に差し替える。error イベントはバブリングしないため、
// document にキャプチャ段階で1つだけリスナーを登録する。
export function replaceBrokenImage(event) {
  const img = event.target
  if (!(img instanceof HTMLImageElement)) return

  const fallback = img.dataset.fallbackSrc
  if (!fallback || img.src === fallback) return

  img.src = fallback
}

document.addEventListener("error", replaceBrokenImage, true)
