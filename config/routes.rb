Rails.application.routes.draw do
  #devise_for :user, only: :none
  scope '/setting' do
    devise_for :user, :controllers =>{
      :registrations => 'user/registrations',
      :sessions => 'user/sessions'
    }
    scope '/files' do
      get '/*pages/:file' =>'files#show'
      get '/:file'=>'files#show'
      get '/'=>'files#index'
      delete '/'=>'files#destroy'
    end
    #devise_for :user do
    #scope '/setting' do
    #  get '/sign_in' => 'user/sessions#new',:as => :new_user_session
    #  post '/sign_in' => 'user/sessions#create',:as => :user_session
    #  delete '/sign_out' =>'user/sessions#destroy',:as => :destroy_user_session
    #  get '/password/new' =>'user/passwords#new',:as => :new_user_password
    #  get '/password/edit'=>'user/passwords#edit',:as=>:edit_user_password
    #  put '/password/' =>'user/passwords#update',:as=>:user_password
    #  patch '/password'=>'user/passwords#update'
    #  post '/password'=>'user/passwords#create'
    #  get '/cancel'=>'user/registrations#cancel',:as=>:cancel_user_registration
    #  get '/sign_up'=>'user/registrations#new',:as=>:new_user_registration
    #  get '/edit' =>'user/registrations#edit',:as=>:edit_user_registration
    #  put '' =>'user/registrations#update',:as=>:user_registration
    #  patch ''=>'user/registrations#update'
    #  delete ''=>'user/registrations#destroy'
    #  post ''=>'user/registrations#create'
    #end

    resources :usergroups
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root to: 'pages#index'
  get    '/new'        => 'pages#new'
  get    '/edit'       => 'pages#edit'
  post   '/'           => 'pages#create'
  put    '/'           => 'pages#update'
  delete '/'           => 'pages#destroy'
  get    '*pages/new'  => 'pages#new'
  get    '*pages/edit' => 'pages#edit'
  get    '*pages/'      => 'pages#index'
  post   '*pages/'      => 'pages#create'
  put    '*pages/'      => 'pages#update'
  delete '*pages/'      => 'pages#destroy'
  #post   '*pages/comments'=>'comments#create'
  #delete '*pages/comments'=>'comments#destroy'
  #post   'comments'    => 'comments#create'
  #delete   'comments'    => 'comments#delete'

end
