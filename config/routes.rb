Rails.application.routes.draw do
  get '/hello' => 'pages#hello'
  get '/hello_300' => 'pages#hello300'
  get '/hello_3000' => 'pages#hello3000'
end
