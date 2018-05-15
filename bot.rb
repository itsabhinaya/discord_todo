require 'discordrb'
require 'dotenv'
require 'google_drive'
require 'time_difference'
require 'net/https'

Dotenv.load
bot = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], client_id: ENV['CLIENT_ID'], prefix: '/'

session = GoogleDrive::Session.from_config("config.json")

ws = session.spreadsheet_by_key(ENV['G_KEY']).worksheets[0]
# allData = ws.rows
# gsNRows = ws.num_rows

# p allData

# ws[gsNRows+1,1] ="yes"
# ws.save
# def user():

#Check if the user is available. If not add another row for them.
def userAvailable(id,ws)
  allData = ws.rows.flatten
  gsNRows = ws.num_rows
  if allData.exclude?(id.to_s)
    ws[gsNRows+1,1] = id
    ws[gsNRows+1,2] = 0
    ws[gsNRows+1,3] = Time.now.utc
    ws[gsNRows+1,4] = 5
    ws.save
    ws.reload
    return true
  end
end

#start with 5
#adds the todo to the user in a new column on the same row
def addTodo(id, message, ws,rowIndex)
allData = ws.rows
# p rowIndex
row = rowIndex + 1
col = allData[rowIndex][3].to_i
ws[row,col] = message
ws[row,4] = col+1
    ws.save
    ws.reload
end

#Shows the list of todo items for the users that wants to know
def showTodo(id,ws,rowIndex)
  allData = ws.rows
  eachCell = allData[rowIndex]
  eachCell = eachCell.drop(4)
  return eachCell
end

  def is_number?(obj)
        obj.to_s == obj.to_i.to_s
    end


p "skdjfn"
bot.command :add  do |event, *args|
	# p args
  id = event.user.id
  args = args.join(' ')
  # print(args)
  message = args
  userAvailable(id,ws)

  allData = ws.rows
  rowIndex = allData.index(allData.detect{|aa| aa.include?(id.to_s)})
  addTodo(id, message, ws,rowIndex)
  # p event.user.inspect
  
  event.respond ("<@#{id}> todo: `#{message}`")

end

bot.command(:todo, description: "Shows your todos as a list.")  do |event|
    id = event.user.id
    allData = ws.rows
    rowIndex = allData.index(allData.detect{|aa| aa.include?(id.to_s)})
    p ("********rowindes: #{rowIndex}")
    p (rowIndex.blank?)

  # if userAvailable(id,ws)
  if rowIndex.blank?
    userAvailable(id,ws)
    event.respond("you don't have any todo's yet")
  else
      todos = showTodo(id,ws,rowIndex)
          print("********todos: #{todos}")

      if todos.empty?
        event.respond("you don't have any todo's yet")
      else
        todoList = []
        num = 1
        todos.each do |item|
          todoList << num.to_s+" " + item
          num += 1
        end
        event.respond("```#{todoList.join("\n")}```")
      end
  end
end


def todoDelete(id,command,ws)
end



bot.command :d do |event, *args|
    id = event.user.id
    allData = ws.rows
    args = args.join(' ')

    p args

    if is_number? args
      todoDelete(id,command,ws)
      event.respond("Yes it is integer")
    else
      event.respond("Command should be a number shown infront of your todos.")
    end
end

bot.run