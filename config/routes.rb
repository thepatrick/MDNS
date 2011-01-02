MDNS::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.
  scope "/knox" do
    resource :gate, :controller => 'user_sessions', :path_names => { :new => 'open' } do
      get 'logout', :action => 'destroy'
    end
    resource :account, :controller => 'users', :path_names => { :new => 'register' }, :except => :destroy
  end
  
  scope "/rw" do
    resources :domains, :except => [:new, :edit] do
      resources :records, :except => [:new, :edit]
      member do
        post 'publish'
      end
    end
    resources :recordtypes, :only => :index
  end
  
  scope '/admin' do
    get '/', :to => "admin#index" 
    resources :users, :controller => 'admin_users', :except => :new
    resources :domains, :controller => 'admin_domains', :as => 'admin_domain', :except => :new do
      put :toggle
    end
  end

  root :to => "home#index"
end
