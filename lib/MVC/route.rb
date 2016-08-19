class Route
  attr_reader :url_pattern, :http_method, :controller_class, :action_name

  def initialize(url_pattern, http_method, controller_class, action_name)
    @url_pattern      = url_pattern
    @http_method      = http_method
    @controller_class = controller_class
    @action_name      = action_name
  end

  def matches?(req)
    !!(req.path =~ url_pattern) &&
      req.request_method.downcase.to_sym == http_method
  end

  def run(req, res)
    match_data = url_pattern.match(req.path)
    route_params = Hash[match_data.names.zip(match_data.captures)]

    controller_class
      .new(req, res, route_params)
      .invoke_action(action_name)
  end
end
