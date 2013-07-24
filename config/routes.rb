Alacarte::Application.routes.draw do
  root to: 'login#login'

  get 'login/login'  => 'login#login',  as: 'login'
  get 'login/logout' => 'login#logout', as: 'logout'

  scope path: '/admin', controller: :admin do
    get 'tools' => :index, as: 'tools'

    resources :dods
    resources :masters
    resources :subjects

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
  end

  resource :dashboard do
    match 'edit_profile', via: [:get, :post]
    match 'my_account',   via: [:get, :post]
    match 'my_profile',   via: [:get, :post]
  end

  resources :guides do
    member do
      match 'copy',          via: [:get, :post]
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      match 'publish',       via: [:get, :post]
      get   'share'
    end

    resources :tabs do
      member do
        post  'add_mod'
        match 'add_modules', via: [:get, :post]
        post  'remove_module'
        post  'reorder_modules'
        post  'toggle_columns'
        post  'delete'
      end
    end
  end

  resources :pages do
    member do
      get   'archive'
      get   'copy'
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      get   'publish'
      get   'share'
    end

    resources :tabs do
      member do
        post  'add_mod'
        match 'add_modules', via: [:get, :post]
        post  'remove_module'
        post  'reorder_modules'
        post  'toggle_columns'
      end
    end
  end

  resources :tutorials do
    member do
      get 'add_units'
      get 'archive'
      get 'copy'
      get 'publish'
      get 'share'
    end

    resources :units do
      member do
        get 'add_modules'
      end
    end
  end

  resources :modules do
    member do
      post  'add_guide'
      post  'add_page'
      match 'add_to_guide',    via: [:get, :post]
      match 'add_to_page',     via: [:get, :post]
      match 'add_to_tutorial', via: [:get, :post]
      post  'add_tutorial'
      get   'copy'
      get   'globalize'
      get   'manage'
      get   'publish'
      get   'remove_user_from_mod'
      get   'share'
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

  scope path: '/course-guide', controller: :ica do
    get ''           => :published_pages
    get 'archived'   => :archived
    get 'tagged/:id' => :tagged
    get ':id'        => :show, as: 'show_ica'
  end

  scope path: '/subject-guide', controller: :srg do
    get ''           => :published_guides, as: 'subject_guides'
    get 'tagged/:id' => :tagged
    get ':id'        => :show, as: 'show_srg'
  end

  get 'internal-guides/' => 'srg#internal_guides'

  scope path: '/tutorial', controller: :ort do
    get ''            => :published_tutorials
    get 'archived'    => :archived_tutorials
    get ':id'         => :index, as: 'show_ort'
    get 'unit/:id'    => :unit
    get 'tagged/:id'  => :tagged
    get 'subject/:id' => :subject_list
  end

  get 'tutorial/my-quizzes/:id'     => 'student#quizzes'
  get 'tutorial/login/:id'          => 'student#login'
  get 'tutorial/create-account/:id' => 'student#create_account'

  get   ':controller/service.wsdl' => '#wsdl'
  match '/:controller(/:action(/:id))'
end
