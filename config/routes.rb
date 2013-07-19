Alacarte::Application.routes.draw do
  root to: 'login#login'

  get 'login/login'  => 'login#login',  as: 'login'
  get 'login/logout' => 'login#logout', as: 'logout'

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

  resource :dashboard do
    match 'edit_profile', via: [:get, :post]
    match 'my_account',   via: [:get, :post]
  end

  resources :guides do
    member do
      get   'copy'
      match 'edit_contact',  via: [:get, :put]
      match 'edit_relateds', via: [:get, :put]
      match 'publish',       via: [:get, :post]
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

  scope path: '/tutorial', controller: :tutorial do
    get   ''                => :index,       as: 'tutorials'
    post  'add_to_list/:id' => :add_to_list
    match 'add_units/:id'   => :add_units,   as: 'add_units', via: [:get, :post]
    get   'archive/:id'     => :archive,     as: 'archive_tutorial'
    get   'copy/:id'        => :copy,        as: 'copy_tutorial'
    post  'create_unit/:id' => :create_unit, as: 'create_unit'
    get   'edit/:id'        => :edit,        as: 'edit_tutorial'
    match 'edit_unit/:id'   => :edit_unit,   as: 'edit_unit', via: [:get, :post]
    get   'new'             => :new,         as: 'new_tutorial'
    get   'new_unit/:id'    => :new_unit,    as: 'new_unit'
    get   'publish/:id'     => :publish,     as: 'publish_tutorial'
    get   'share/:id'       => :share,       as: 'share_tutorial'
    get   'units/:id'       => :units,       as: 'units'
    post  'update/:id'      => :update,      as: 'update_tutorial'
  end

  resources :tabs do
    member do
      post  'add_mod'
      match 'add_modules', via: [:get, :post]
      post  'remove_module'
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

  scope path: '/course-guides', controller: :ica do
    get ''           => :published_pages
    get 'archived'   => :archived
    get 'tagged/:id' => :tagged
    get ':id'        => :index
  end

  scope path: '/subject-guides', controller: :srg do
    get ''           => :published_guides
    get 'tagged/:id' => :tagged
    get ':id'        => :index, as: 'show_srg'
  end

  get 'internal-guides/' => 'srg#internal_guides'

  scope path: '/tutorials', controller: :ort do
    get ''            => :published_tutorials
    get 'archived'    => :archived_tutorials
    get ':id'         => :index, as: 'show_ort'
    get 'unit/:id'    => :unit
    get 'tagged/:id'  => :tagged
    get 'subject/:id' => :subject_list
  end

  get 'tutorials/my-quizzes/:id'     => 'student#quizzes'
  get 'tutorials/login/:id'          => 'student#login'
  get 'tutorials/create-account/:id' => 'student#create_account'

  get ':controller/service.wsdl' => '#wsdl'
  match '/:controller(/:action(/:id))'
end
