class AddPositionToFeaturedSlides < ActiveRecord::Migration[8.1]
  # マイグレーション内だけで使うモデル（アプリのモデルが将来変わっても影響を受けないように）
  class MigrationFeaturedSlide < ApplicationRecord
    self.table_name = 'featured_slides'
  end

  def up
    add_column :featured_slides, :position, :integer, null: false, default: 0
    add_index :featured_slides, :position

    # これまでの表示順（追加日時の新しい順）をそのまま並び順にする。MySQL 5.7 でも動くよう Ruby で番号を振る
    MigrationFeaturedSlide.reset_column_information
    MigrationFeaturedSlide.order(created_at: :desc, id: :desc).each.with_index(1) do |featured, position|
      featured.update_column(:position, position)
    end
  end

  def down
    remove_index :featured_slides, :position
    remove_column :featured_slides, :position
  end
end
