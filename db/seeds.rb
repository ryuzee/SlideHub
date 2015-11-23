# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.connection.execute('TRUNCATE TABLE categories;')
Category.create([
  { id: 1, name: 'Books' },
  { id: 2, name: 'Business' },
  { id: 3, name: 'Design' },
  { id: 4, name: 'Education' },
  { id: 5, name: 'Entertainment' },
  { id: 6, name: 'Finance' },
  { id: 7, name: 'Games' },
  { id: 8, name: 'Health' },
  { id: 9, name: 'How-to & DIY' },
  { id: 10, name: 'Humor' },
  { id: 11, name: 'Photos' },
  { id: 12, name: 'Programming' },
  { id: 13, name: 'Research' },
  { id: 14, name: 'Science' },
  { id: 15, name: 'Technology' },
  { id: 16, name: 'Travel' },
])
