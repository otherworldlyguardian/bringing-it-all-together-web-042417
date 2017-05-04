require_relative "../config/environment"

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(args)
    @name = args[:name]
    @breed = args[:breed]
    @id ||= args[:id]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    test = DB[:conn].execute("SELECT id FROM dogs DESC LIMIT 1")[0]
    @id = test[0]
    update if self.name != test[1]
    self
  end

  def self.create(args)
    self.new(args).save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      SQL

    Dog.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(args)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      SQL

    arr = DB[:conn].execute(sql, args[:name], args[:breed])
    if !arr.empty?
      dog = self.new_from_db(arr[0])
    else
      dog = self.create(args)
      dog = Dog.new_from_db(DB[:conn].execute(sql, dog.name, dog.breed)[0])
    end
    dog
  end

  def self.new_from_db(row)
    hash = {id:row[0], name:row[1], breed:row[2]}
    Dog.new(hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      SQL

    Dog.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE id = ?
      SQL

    DB[:conn].execute(sql, self.name, self.id)
  end

end
