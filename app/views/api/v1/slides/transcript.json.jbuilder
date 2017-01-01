json.prettify!
transcripts = []
@slide.transcript.each do |t|
  transcripts.push t
end
json.transcripts transcripts
