# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
if Category.count.zero?
  Category.create([
                    { id: 1, name_en: 'Books', name_ja: '書籍' },
                    { id: 2, name_en: 'Business', name_ja: 'ビジネス' },
                    { id: 3, name_en: 'Design', name_ja: 'デザイン' },
                    { id: 4, name_en: 'Education', name_ja: '教育' },
                    { id: 5, name_en: 'Entertainment', name_ja: 'エンターテイメント' },
                    { id: 6, name_en: 'Finance', name_ja: 'ファイナンス' },
                    { id: 7, name_en: 'Games', name_ja: 'ゲーム' },
                    { id: 8, name_en: 'Health', name_ja: 'ヘルス' },
                    { id: 9, name_en: 'How-to & DIY', name_ja: 'DIY' },
                    { id: 10, name_en: 'Humor', name_ja: 'ユーモア' },
                    { id: 11, name_en: 'Photos', name_ja: '写真' },
                    { id: 12, name_en: 'Programming', name_ja: 'プログラミング' },
                    { id: 13, name_en: 'Research', name_ja: 'リサーチ' },
                    { id: 14, name_en: 'Science', name_ja: 'サイエンス' },
                    { id: 15, name_en: 'Technology', name_ja: 'テクノロジー' },
                    { id: 16, name_en: 'Travel', name_ja: '旅行' },
                  ])
end

if User.where(admin: true).count.zero?
  admin = User.new(
    email: 'admin@example.com',
    password: 'passw0rd',
    password_confirmation: 'passw0rd',
    display_name: 'admin',
    biography: 'Administrator',
    admin: true,
    username: 'admin-default',
  )
  admin.save(validate: false)
end
