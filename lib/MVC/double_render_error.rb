class DoubleRenderError < StandardError
  def initialize(msg='double render error')
    super(msg)
  end
end
