class AddImageFormatToSlides < ActiveRecord::Migration[8.1]
  # ページ画像とサムネイルの形式（拡張子）。今あるスライドは jpg で、これから変換するスライドは webp にする
  def change
    add_column :slides, :image_format, :string, limit: 10, null: false, default: 'jpg'
  end
end
