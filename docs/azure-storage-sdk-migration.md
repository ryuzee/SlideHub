# Azure Storage の SDK の置き換え（保留中）

## 結論

Azure で動かすときに使っている `azure-storage-blob`・`azure-storage-queue`（とその依存の `azure-storage-common`）は、開発が止まった SDK です。不具合や脆弱性が見つかっても直らないので、いずれ置き換える必要がある。ただし作業が大きいため、2026 年 11 月の時点では保留にしている。

- 最後のリリースは、3 つとも 2021-12-06（blob 2.0.3、queue 2.0.4、common 2.0.4）
- 元のリポジトリ（github.com/azure/azure-storage-ruby）も、それ以降更新されていない
- 今のところ動作に問題はない。急ぐ理由ができるのは、次のどれかが起きたとき
  - SDK に脆弱性が見つかった
  - Ruby や Rails の更新で SDK が動かなくなった
  - Azure Storage の API の古い版が使えなくなった

## SDK を使っているところ

| ファイル | 使っている機能 | 何に使っているか |
| --- | --- | --- |
| `lib/slide_hub/cloud/engine/azure.rb` | Queue：メッセージの送信・受信・削除、件数の取得 | 変換の依頼（バッチが受け取る） |
| 同上 | Blob：アップロード、一覧、ダウンロード、削除、コピー（コピーの完了待ちを含む） | スライドの元ファイルと、変換して作った画像の置き場所 |
| 同上 | SAS（署名付き URL）の作成 | ブラウザから直接アップロードする URL（`app/views/slides/azure/_upload_js.erb`）と、ダウンロードの URL |
| `lib/active_storage/service/azure_storage_service.rb` | Blob 一式と SAS | Active Storage（アバター画像）の保存先。Rails 本体から Azure 用のサービスが外れたので、自前で持っている |

AWS（S3・SQS）の側は `aws-sdk-s3`・`aws-sdk-sqs` を使っていて、こちらは開発が続いているので対象外。

## 置き換え先の候補

- **Blob と SAS：`azure-blob` gem**（github.com/testdouble/azure-blob）
  - Rails の Active Storage の Azure 用サービスの後継として作られたもので、今も更新されている（0.9.0 は 2026-10-11）
  - アップロード、ダウンロード（範囲指定）、一覧、削除、SAS の作成は揃っている見込み。コピーと、コピーの完了待ちに使っているプロパティ（`copy_status`）が使えるかは、着手するときに確かめる
  - Active Storage 用のサービスも同梱されている見込みなので、`lib/active_storage/service/azure_storage_service.rb` は消せる可能性が高い
- **Queue：REST API を直接呼ぶ小さなクラスを書く**
  - 今使っている操作は 5 つ（作成、送信、受信、削除、件数の取得）だけなので、Net::HTTP と共有キーの署名で書ける
  - 署名の処理は `azure-blob` の中身を参考にできる

## 進め方の案

1. `lib/slide_hub/cloud/engine/azure.rb` の公開メソッド（`send_message`、`receive_message`、`upload_files`、`copy_slide`、`generate_sas_url` など）の振る舞いを、置き換え前のテストで固める。今のテストはこのエンジンをほとんど通っていないので、ここが一番の手間になる
2. Blob を `azure-blob` に替える（エンジンと Active Storage の両方）
3. Queue を自前のクラスに替える
4. Azure の実環境（開発用のストレージアカウント）で、次を通しで確かめる
   - アップロード
   - 変換（キューの受信と削除）
   - 再変換（キーの切り替えと古いファイルの削除）
   - ダウンロード
   - アバターの登録
5. 本番に出したら、変換が止まっていないこと（キューにメッセージが溜まっていないこと）を見る

## 気をつけること

- ブラウザから直接アップロードする処理は、SAS の URL にブロック単位で PUT している（`_upload_js.erb`）。SAS の権限と有効期限の作り方が変わると、アップロードが失敗する
- 再変換のときは、新しいキーに元ファイルをコピーしてから古いファイルを消している（`copy_slide` と `SlideHub::SlideKeyCleanup`）。コピーの完了を待つ処理が正しく動くかは、実環境でしか確かめられない
- 開発環境の `docker-compose-azure.yml` で Azure 用の構成を動かせるので、置き換えの確認にはこれを使う
