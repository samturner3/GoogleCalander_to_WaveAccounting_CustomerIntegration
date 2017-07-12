Rails.application.routes.draw do
  get 'acuity/test'

  resources :clients do
    resources :bookings
  end
  devise_for :users, controllers: { registrations: "registrations"}


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

root 'bookings#new'

# get '/redirect', to: 'bookings#redirect', as: 'redirect'
# get '/callback', to: 'bookings#new', as: 'callback'
get '/calendars', to: 'main#calendars', as: 'calendars'
get '/events/:calendar_id', to: 'main#events', as: 'events', calendar_id: /[^\/]+/
get '/calendars/downloadCBD', to: 'main#downloadCBD'
get '/calendars/downloadCALLOUT', to: 'main#downloadCALLOUT'

get '/bookings/index', to: 'bookings#index'

get '/acuity/test', to: 'acuity#test'

get '/clients/sendTestimonialRequest/:id', to: 'clients#sendTestimonialRequest', as: 'sendTestimonialRequest'

#api
namespace :api do
  namespace :v1 do
    resources :users, only: [:index, :create, :show, :update, :destroy]
    resources :microposts, only: [:index, :create, :show, :update, :destroy]
  end
end

end
