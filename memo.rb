class Memo
  DB = 'db/db.csv'
  LATEST_ID_FILE = 'db/latest_id'

  class << self
    def all
      csv_table.map { |row| Memo.new(row.to_hash) }
    end

    def find(id)
      all.find { |memo| memo.id == id.to_i }
    end

    def create(title: title, body: body)
      write(csv_table << [new_id, title, body])
      update_latest_id
    end

    def update(id:, title:, body:)
      table = csv_table
      row = table.find { |row| row[:id] == id }
      row[:title] = title
      row[:body] = body
      write(table)
    end

    def delete(id:)
      table = csv_table
      table.delete_if { |row| row[:id] == id }
      write(table)
    end

    private

    def csv_table
      CSV.table(DB, headers: %w(id title body))
    end

    def new_id
      File.read(LATEST_ID_FILE).to_i + 1
    end

    def write(table)
      File.write(DB, table.to_s(write_headers: false))
    end

    def update_latest_id
      File.open(LATEST_ID_FILE, 'r+') do |f|
        f.flock(File::LOCK_EX)
        new_id = f.read.succ
        f.rewind
        f.write(new_id)
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
