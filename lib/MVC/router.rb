require_relative 'route'

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(url_pattern, http_method, controller_class, action_name)
    routes << Route.new(
      url_pattern,
      http_method,
      controller_class,
      action_name
    )
  end

  def draw(&proc)
    instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |url_pattern, controller_class, action_name|
      add_route(url_pattern, http_method, controller_class, action_name)
    end
  end

  def match(req)
    routes.find { |route| route.matches?(req) }
  end

  def run(req, res)
    matching_route = match(req)

    if matching_route
      matching_route.run(req, res)
    else
      res.status = 404
    end
  end
end
