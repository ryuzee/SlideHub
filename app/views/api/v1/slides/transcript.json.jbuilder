json.prettify!
transcripts = []
@slide.transcript.lines.each do |t|
  transcripts.push clear_invisible_string(t)
end
json.transcripts transcripts
