Alacarte::Application.routes.draw do
  root :to => 'login#login'
  get ':controller/service.wsdl' => '#wsdl'
  get 'course-guides/' => 'ica#published_pages'
  get 'course-guides/archived/' => 'ica#archived'
  get 'course-guides/tagged/:id' => 'ica#tagged'
  get 'course-guide/:id' => 'ica#index'
  get 'subject-guides/' => 'srg#published_guides'
  get 'subject-guides/tagged/:id' => 'srg#tagged'
  get 'subject-guide/:id' => 'srg#index', :as => 'show_srg'
  get 'guides/search/' => 'srg#search'
  get 'internal-guides/' => 'srg#internal_guides'
  get 'tutorials' => 'ort#published_tutorials'
  get 'tutorials/archived/' => 'ort#archived_tutorials'
  get 'tutorials/:id' => 'ort#index'
  get 'tutorials/unit/:id' => 'ort#unit'
  get 'tutorials/lesson/:id' => 'ort#lesson'
  get 'tutorials/tagged/:id' => 'ort#tagged'
  get 'tutorials/subject/:id' => 'ort#subject_list'
  get 'tutorials/my-quizzes/:id' => 'student#quizzes'
  get 'tutorials/login/:id' => 'student#login'
  get 'tutorials/create-account/:id' => 'student#create_account'

  get 'admin/tools' => 'admin#tools', :as => 'show_tools'

  get 'dashboard' => 'dashboard#index', :as => 'show_dashboard'

  get 'guide' => 'guide#index', :as => 'list_guides'
  get 'guide/copy/:id' => 'guide#copy', :as => 'copy_guide'
  get 'guide/destroy/:id' => 'guide#destroy', :as => 'delete_guide'
  get 'guide/edit/:id' => 'guide#edit', :as => 'edit_guide'

  get 'login/logout' => 'login#logout', :as => 'logout'

  get 'module' => 'module#index', :as => 'list_modules'

  get 'page' => 'page#index', :as => 'list_pages'

  get 'tutorial' => 'tutorial#index', :as => 'list_tutorials'

  match '/:controller(/:action(/:id))'
end
