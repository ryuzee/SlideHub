// 管理画面「注目のスライド」の並べ替え。
// ドラッグ＆ドロップか上下ボタンで並べ替えると、並びをサーバーに送ってすぐに保存する。
// 先頭 data-top-limit 件には「トップに表示」のバッジを付ける。

function items(list) {
  return Array.from(list.querySelectorAll(".featured-slide-item"))
}

// 番号と「トップに表示」バッジ、上下ボタンの有効/無効を今の並びに合わせる
function refresh(list) {
  const limit = Number(list.dataset.topLimit || 0)
  const all = items(list)
  all.forEach((item, index) => {
    item.querySelector(".featured-position").textContent = index + 1
    item.querySelector(".featured-top-badge").classList.toggle("d-none", index >= limit)
    item.querySelector(".js-move-up").disabled = index === 0
    item.querySelector(".js-move-down").disabled = index === all.length - 1
  })
}

function showToast(message, error) {
  let container = document.querySelector(".toast-container")
  if (!container) {
    container = document.createElement("div")
    container.className = "toast-container position-fixed top-0 end-0 p-3"
    container.style.zIndex = 1090
    document.body.appendChild(container)
  }
  const toast = document.createElement("div")
  toast.className = `toast align-items-center border-0 ${error ? "text-bg-danger" : "text-bg-success"}`
  toast.setAttribute("role", error ? "alert" : "status")
  toast.innerHTML = '<div class="d-flex"><div class="toast-body"></div>' +
    '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button></div>'
  toast.querySelector(".toast-body").textContent = message
  container.appendChild(toast)
  window.bootstrap.Toast.getOrCreateInstance(toast, { delay: 3000 }).show()
}

async function save(list) {
  const token = document.querySelector('meta[name="csrf-token"]')?.content
  const ids = items(list).map((item) => item.dataset.id)
  try {
    const response = await fetch(list.dataset.reorderUrl, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": token, Accept: "application/json" },
      credentials: "same-origin",
      body: JSON.stringify({ ids }),
    })
    if (!response.ok) throw new Error(response.statusText)
    showToast(list.dataset.textSaved, false)
  } catch (_error) {
    showToast(list.dataset.textFailed, true)
  }
}

function changed(list) {
  refresh(list)
  save(list)
}

export function setupFeaturedSlidesSort(list) {
  let dragging = null

  list.addEventListener("dragstart", (event) => {
    dragging = event.target.closest(".featured-slide-item")
    if (!dragging) return
    dragging.classList.add("opacity-50")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", dragging.dataset.id)
  })

  list.addEventListener("dragover", (event) => {
    if (!dragging) return
    event.preventDefault()
    const target = event.target.closest(".featured-slide-item")
    if (!target || target === dragging) return
    const rect = target.getBoundingClientRect()
    const after = event.clientY > rect.top + rect.height / 2
    target.parentNode.insertBefore(dragging, after ? target.nextSibling : target)
  })

  list.addEventListener("dragend", () => {
    if (!dragging) return
    dragging.classList.remove("opacity-50")
    dragging = null
    changed(list)
  })

  list.addEventListener("click", (event) => {
    const button = event.target.closest(".js-move-up, .js-move-down")
    if (!button) return
    const item = button.closest(".featured-slide-item")
    if (button.classList.contains("js-move-up") && item.previousElementSibling) {
      item.parentNode.insertBefore(item, item.previousElementSibling)
    } else if (button.classList.contains("js-move-down") && item.nextElementSibling) {
      item.parentNode.insertBefore(item.nextElementSibling, item)
    } else {
      return
    }
    changed(list)
    button.focus()
  })

  refresh(list)
}

document.addEventListener("DOMContentLoaded", () => {
  const list = document.getElementById("featured-slides-sortable")
  if (list) setupFeaturedSlidesSort(list)
})
