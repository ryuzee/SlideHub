# Rails 5.0 のときから古い動きのまま固定している設定。
# フォームごとの CSRF トークンと belongs_to の必須化は、いまの Rails の標準（load_defaults 8.1）に戻した。

# Origin ヘッダーの確認は、本番の前段（Azure 側）が Host や X-Forwarded-Proto をどう渡すかによって、
# ログインなどの送信がすべて弾かれるおそれがある。先に OriginCheckLogging で食い違いがないかをログで確かめ、
# 出ていなければこの行を消して有効にする
Rails.application.config.action_controller.forgery_protection_origin_check = false
