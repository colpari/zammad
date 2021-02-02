Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/history/:object_type/:attribute/after/:time',  to: 'history#by_type_attr_time',  via: :get, constraints: { time: /[^\/]+/ }
end
