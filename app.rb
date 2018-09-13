require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'barbershop.sqlite'
  db.results_as_hash = true
  return db
end

configure do #<-- this will execute on app start

  db = get_db
  db.execute "CREATE TABLE IF NOT EXISTS visitors(
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT,
   phone TEXT,
   datestamp TEXT,
   master TEXT,
   color TEXT);"
  db.execute "CREATE TABLE IF NOT EXISTS masters(
   id INTEGER PRIMARY KEY AUTOINCREMENT,
   name TEXT UNIQUE);"
  db.execute "INSERT OR IGNORE INTO masters(name) VALUES(?)", ["Walter White"]
  db.execute "INSERT OR IGNORE INTO masters(name) VALUES(?)", ["Jessie Pinkman"]
  db.execute "INSERT OR IGNORE INTO masters(name) VALUES(?)", ["Gus Frig"]
end

before do
  db = get_db
  @showall = db.execute "SELECT * FROM visitors"
  @masters = db.execute "SELECT name FROM masters"
end


get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do

	erb :visit

end

get '/contacts' do
  erb :contacts

end

get '/showvisitors' do

  erb :showvisitors
end

post '/visit' do

  @name = params[:username]
	@phone = params[:phone]
	@date = params[:datetime]
  @master = params[:master]
  @color = params[:colorpicker]

  if @name != "" && @phone != "" && @date != ""

    @ok_message = "Thank you, #{@name}! We'll be waiting for you at #{@date}"

   #f = File.open('./public/visitors.txt', 'a')
   #f.write "Name: #{@name}, Phone: #{@phone}, Visit date: #{@date}, Master: #{@master}, Color: #{@color} \n"
   #f.close


   #db.execute "INSERT INTO visitors (name) VALUES (#{@name});"
    db = get_db
    db.execute "INSERT INTO visitors (name, phone, datestamp, master, color) VALUES (?, ?, ?, ?, ?)", [@name,@phone, @date, @master, @color]
    return erb :visit

  end

  errors = {:username => "Please enter your name",
            :phone => "Please enter your phone number",
            :datetime => "Please choose visit date"}
  errors.each do |key, value|
      if params[key]==""
        @error = errors[key]
        return erb :visit
      end
    end
end

post '/contacts' do
  @email = params[:email]
  @message = params[:message]
  #f = File.open('./public/contacts.txt', 'a')
  #f.write " \n From: #{@email}\n Message: #{@message} \n ********************************************************** \n"
  #f.close
  @sent_message = "Спасибо! Ваше сообщение отправлено"
  db = get_db
  db.execute "INSERT INTO contacts (email, message) VALUES (?, ?)", [@email, @message]
  erb :contacts

end