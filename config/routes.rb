MDNS::Application.routes.draw do

  # The priority is based upon order of creation:
  # first created -> highest priority.
  scope "/knox" do
    resource :gate, :controller => 'user_sessions' do
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

  root :to => "home#index"
end
