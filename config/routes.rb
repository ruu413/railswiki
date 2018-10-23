Rails.application.routes.draw do
  #devise_for :user, only: :none
  scope '/setting' do
    devise_for :user do
    #scope '/setting' do
      get '/sign_in' => 'devise/sessions#new',:as => :new_user_session
      post '/sign_in' => 'devise/sessions#create',:as => :user_session
      delete '/sign_out' =>'devise/sessions#destroy',:as => :destroy_user_session
      get '/password/new' =>'devise/passwords#new',:as => :new_user_password
      get '/password/edit'=>'devise/passwords#edit',:as=>:edit_user_password
      put '/password/' =>'devise/passwords#update',:as=>:user_password
      patch '/password'=>'devise/passwords#update'
      post '/password'=>'devise/passwords#create'
      get '/cancel'=>'devise/registrations#cancel',:as=>:cancel_user_registration
      get '/sign_up'=>'devise/registrations#new',:as=>:new_user_registration
      get '/edit' =>'devise/registrations#edit',:as=>:edit_user_registration
      put '' =>'devise/registrations#update',:as=>:user_registration
      patch ''=>'devise/registrations#update'
      delete ''=>'devise/registrations#destroy'
      post ''=>'devise/registrations#create'
    end

    resources :usergroups
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root to: 'pages#index'
  get    '/new'        => 'pages#new'
  get    '/edit'       => 'pages#edit'
  post   '/'           => 'pages#create'
  put    '/'           => 'pages#update'
  delete '/'           => 'pages#delete'
  get    '*pages/new'  => 'pages#new'
  get    '*pages/edit' => 'pages#edit'
  get    '*pages'      => 'pages#index'
  post   '*pages'      => 'pages#create'
  put    '*pages'      => 'pages#update'
  delete '*pages'      => 'pages#destroy'
end
