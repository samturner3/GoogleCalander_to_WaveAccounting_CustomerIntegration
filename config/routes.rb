Rails.application.routes.draw do
  resources :contacts
  devise_for :users, controllers: { registrations: "registrations"}


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

root 'main#redirect'

get '/redirect', to: 'main#redirect', as: 'redirect'
get '/callback', to: 'bookings#new', as: 'callback'
get '/calendars', to: 'main#calendars', as: 'calendars'
get '/events/:calendar_id', to: 'main#events', as: 'events', calendar_id: /[^\/]+/
get '/calendars/downloadCBD', to: 'main#downloadCBD'
get '/calendars/downloadCALLOUT', to: 'main#downloadCALLOUT'

get '/bookings/index', to: 'bookings#index'

end
