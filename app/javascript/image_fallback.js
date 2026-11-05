// サムネイル画像が読み込めないとき（S3 側のファイルが無いなど）、
// data-fallback-src に空白区切りで並べた候補を前から順に試す。
// error イベントはバブリングしないため、document にキャプチャ段階で1つだけリスナーを登録する。
export function replaceBrokenImage(event) {
  const img = event.target
  if (!(img instanceof HTMLImageElement)) return

  const candidates = (img.dataset.fallbackSrc || "").split(/\s+/).filter(Boolean)
  const next = candidates.shift()
  if (!next || img.src === next) return

  img.dataset.fallbackSrc = candidates.join(" ")
  img.src = next
}

document.addEventListener("error", replaceBrokenImage, true)
