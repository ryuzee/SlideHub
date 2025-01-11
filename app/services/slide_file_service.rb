class SlideFileService
  def initialize(slide)
    @slide = slide
  end

  def delete_files
    CloudConfig::provider.delete_slide(@slide.object_key)
    CloudConfig::provider.delete_generated_files(@slide.object_key)
  end
end
