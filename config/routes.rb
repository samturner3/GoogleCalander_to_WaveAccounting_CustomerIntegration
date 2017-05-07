Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

get '/redirect', to: 'main#redirect', as: 'redirect'
get '/callback', to: 'main#callback', as: 'callback'
get '/calendars', to: 'main#calendars', as: 'calendars'
get '/events/:calendar_id', to: 'main#events', as: 'events', calendar_id: /[^\/]+/
get '/calendars/downloadCSV', to: 'main#downloadCSV'

end
