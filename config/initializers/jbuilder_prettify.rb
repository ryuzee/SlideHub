require "jbuilder"

class Jbuilder
  ##
  # Allows you to set @prettify manually in your .jbuilder files.
  # Example:
  #   json.prettify true
  #   json.prettify false
  #
  attr_accessor :prettify

  alias_method :_original_target, :target!

  ##
  # A shortcut to enabling prettify.
  # Example:
  #   json.prettify!
  #
  def prettify!
    @prettify = true
  end

  def target!
    @prettify ? ::JSON.pretty_generate(@attributes) : _original_target
  end
end
