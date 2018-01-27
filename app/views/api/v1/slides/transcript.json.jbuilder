json.prettify!
transcripts = []
@slide.transcript.each do |t|
  transcripts.push clear_invisible_string(t)
end
json.transcripts transcripts
