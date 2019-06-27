require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'csv'
require_relative 'memo.rb'

ROOT_DIR = File.expand_path(File.dirname(__FILE__))
also_reload File.join(ROOT_DIR, 'memo.rb')

# index
get '/' do
  slim :index, locals: { memos: Memo.all }
end

get '/memos' do
  redirect to('/')
end

# show
get %r{/memos/(\d+)} do |id|
  slim :show, locals: { memo: Memo.find(id) }
end

# new
get '/memos/new' do
  slim :new
end

# create
post '/memos' do
  Memo.create(title: params['title'], body: params['body'])
  redirect to('/')
end

# edit
get %r{/memos/(\d+)/edit} do |id|
  slim :edit, locals: { memo: Memo.find(id) }
end

# update
patch %r{/memos/(\d+)} do |id|
  Memo.find(id).update(title: params['title'], body: params['body'])
  redirect to("/memos/#{id}")
end

# delete
delete %r{/memos/(\d+)} do |id|
  Memo.find(id).delete
  redirect to('/')
end
