json.prettify!
json.extract! @slide, 'id', 'user_id', 'name', 'description', 'category_id', 'object_key', 'extension', 'num_of_pages', 'created_at', 'category_name'
json.extract! @slide.user, 'username'
json.thumbnail_url @slide.thumbnail.url
json.transcript_url @slide.transcript.url
tags = []
@slide.tags.each do |t|
  tags.push(t)
end
json.tags tags
