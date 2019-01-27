class SlideConvertService
  def initialize(slide)
    @slide = slide
  end

  def send_request
    CloudConfig::SERVICE.send_message({ id: @slide.id, object_key: @slide.object_key }.to_json)
  end
end
