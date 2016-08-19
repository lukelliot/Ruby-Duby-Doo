require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './double_render_error'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params={})
    @req, @res = req, res
    @params = route_params.merge(req.params)
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise DoubleRenderError if already_built_response?

    res['Location'], res.status = url, 302

    @already_built_response = true

    session.store_session(res)

    nil
  end

  def render_content(content, content_type)
    raise DoubleRenderError if already_built_response?

    res.write(content)
    res['Content-Type'] = content_type

    @already_built_response = true

    session.store_session(res)

    nil
  end

  def render(template_name)
    controller = "#{self.class.name.underscore.gsub('_controller', '')}"
    template = "#{template_name}.html.erb"

    template_path = File.join('views', controller, template)

    template_code = File.read(template_path)

    render_content(
      ERB.new(template_code).result(binding),
      'text/html'
    )
  end

  def session
    @session ||= Session.new(req)
  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
