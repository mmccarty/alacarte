Alacarte::Application.routes.draw do
  root to: 'login#login'

  get 'login/login'  => 'login#login',  as: 'login'
  get 'login/logout' => 'login#logout', as: 'logout'

  resources :modules do
    member do
      get 'copy'
      get 'globalize'
      get 'manage'
      get 'publish'
      get 'remove_user_from_mod'
      get 'share'
    end
  end

  resources :comment_resources
  resources :database_resources
  resources :inst_resources
  resources :lib_resources
  resources :miscellaneous_resources
  resources :quiz_resources
  resources :rss_resources
  resources :url_resources

  scope path: '/admin', controller: :admin do
    resources :dods, :masters, :subjects
    resources :users do
      collection do
        get 'email_list'
        get 'pending'
      end
      member do
        post 'approve'
        post 'deny'
      end
    end
    get 'tools' => :index, as: 'tools'
  end

  scope path: '/course-guides', controller: :ica do
    get ''           => :published_pages
    get 'archived'   => :archived
    get 'tagged/:id' => :tagged
    get ':id'        => :index
  end

  resource :dashboard, controller: :dashboard

  resources :guides do
    member do
      get   'copy'
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      get   'publish'
      get   'share'
    end
  end

  resources :pages do
    member do
      get   'copy'
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      get   'publish'
      get   'share'
    end
  end

  scope path: '/subject-guides', controller: :srg do
    get ''           => :published_guides
    get 'tagged/:id' => :tagged
    get ':id'        => :index, as: 'show_srg'
  end

  get 'internal-guides/' => 'srg#internal_guides'

  resources :tabs do
    member do
      post  'add_mod'
      match 'add_modules', via: [:get, :post]
      post  'remove_module'
    end
  end

  scope path: '/tutorial', controller: :tutorial do
    get  ''           => :index,  as: 'tutorials'
    get  'copy/:id'   => :copy,   as: 'copy_tutorial'
    get  'new'        => :new,    as: 'new_tutorial'
    post 'update/:id' => :update, as: 'update_tutorial'
  end

  scope path: '/tutorials', controller: :ort do
    get ''            => :published_tutorials
    get 'archived'    => :archived_tutorials
    get ':id'         => :index
    get 'unit/:id'    => :unit
    get 'tagged/:id'  => :tagged
    get 'subject/:id' => :subject_list
  end

  get 'tutorials/my-quizzes/:id'     => 'student#quizzes'
  get 'tutorials/login/:id'          => 'student#login'
  get 'tutorials/create-account/:id' => 'student#create_account'

  scope path: '/unit', controller: :unit do
    post 'create'     => :create, as: 'create_unit'
    get  'new'        => :new,    as: 'new_unit'
    post 'update/:id' => :update, as: 'update_unit'
  end

  get ':controller/service.wsdl' => '#wsdl'
  match '/:controller(/:action(/:id))'
end
