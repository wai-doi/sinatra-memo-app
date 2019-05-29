require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'csv'

# index
get '/' do
  slim :index, locals: { memos: Memo.all }
end

# show
get %r{/(\d+)} do |id|
  slim :show, locals: { memo: Memo.find(id) }
end

# new
get '/new' do
  slim :new
end

# create
post '/' do
  Memo.create(title: params['title'], body: params['body'])
  redirect to('/')
end

# edit
get %r{/edit/(\d+)} do |id|
  slim :edit, locals: { memo: Memo.find(id) }
end

# update
patch %r{/(\d+)} do |id|
  Memo.find(id).update(title: params['title'], body: params['body'])
  redirect to("/#{id}")
end

# delete
delete %r{/(\d+)} do |id|
  Memo.find(id).delete
  redirect to('/')
end


class Memo
  DB = 'db/db.csv'
  LATEST_ID_FILE = 'db/latest_id'

  class << self
    def all
      CSV.foreach(DB).map { |line|
        Memo.new(id: line[0], title: line[1], body: line[2])
      }
    end

    def find(id)
      all.find { |memo| memo.id == id.to_i }
    end

    def create(title: title, body: body)
      add_new_record(title, body)
      update_latest_id
    end

    def update(id:, title:, body:)
      replace_db_with(updated_csv_data(id, title, body))
    end

    def delete(id:)
      replace_db_with(deleted_csv_data(id))
    end

    private

    def new_id
      File.read(LATEST_ID_FILE).to_i + 1
    end

    def add_new_record(title, body)
      CSV.open(DB, 'a') do |csv|
        csv << [new_id, title, body]
      end
    end

    def update_latest_id
      File.write(LATEST_ID_FILE, "#{new_id}")
    end

    def updated_csv_data(id, title, body)
      CSV.generate { |csv|
        all.each do |memo|
          if memo.id == id.to_i
            csv << [id, title, body]
          else
            csv << [memo.id, memo.title, memo.body]
          end
        end
      }
    end

    def deleted_csv_data(id)
      CSV.generate { |csv|
        all.each do |memo|
          next if memo.id.to_i == id.to_i
          csv << [memo.id, memo.title, memo.body]
        end
      }
    end

    def replace_db_with(csv_data)
      File.open(DB, 'w') do |f|
        f.write(csv_data)
      end
    end
  end

  attr_reader :id, :title, :body

  def initialize(id:, title:, body:)
    @id = id.to_i
    @title = title
    @body = body
  end

  def update(title:, body:)
    Memo.update(id: @id, title: title, body: body)
  end

  def delete
    Memo.delete(id: @id)
  end
end
