class SlideFileService
  def initialize(slide)
    @slide = slide
  end

  def delete_files
    CloudConfig::PROVIDER_ENGINE.delete_slide(@slide.object_key)
    CloudConfig::PROVIDER_ENGINE.delete_generated_files(@slide.object_key)
  end
end
