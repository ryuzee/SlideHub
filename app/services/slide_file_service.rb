class SlideFileService
  def initialize(slide)
    @slide = slide
  end

  def delete_files
    CloudConfig::SERVICE.delete_slide(@slide.object_key)
    CloudConfig::SERVICE.delete_generated_files(@slide.object_key)
  end
end
