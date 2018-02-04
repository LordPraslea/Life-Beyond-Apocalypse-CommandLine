defmodule GameDatabase do
  require Logger

  @moduledoc  """
  This module imports all the JSON files linking them together
  Items
  Recipes
  Terrains
  Groups

  """

  @database :game_database

  @doc  """
  Adds the data to the appropiate  object
  based on the type it adds the id
  """
  def add_to_appropiate_object() do

  end

  @doc  """
    Goes over all the files in the json folder and transforms each one
    into elixir data structures (lists, keys,maps)
    Then iterates over each one of them adding it to
    the appropiate key/value structure.

    At first we will use a nested structure.. maybe later we will convert it

    %GlobalMap{%"type" =>  %{"id" => "object" } }

    We know that each json file has a list of objects [{...},{...},{...},..]
   @TODO file which stores a sha1 hash of all JSON files
    if something has changed, go over the changed files
    reloading the data
  """
  def convert_all_json_to_elixir_data(json_folder \\ "data/json/",
    output_file \\ "data/game/life_beyond_apocalypse.db") do
    json_files = FileExt.ls_r(json_folder)
    DataStorage.start(@database, DataStorage, :new, %{})
    Enum.each(~w/uncraft names name_to_id/,  &create_category_for_type(&1, %{}))
    Enum.each(json_files, fn (file) ->
        #Logger.debug "Parsing file #{file}"
        json = File.read!(file)
        object_list = Poison.decode!(json)
        if is_list(object_list) do
             Enum.each(object_list, &handle_object(&1))
         else
            handle_object(object_list)
        end
    end)

    #Truncates map data:)
  #  File.write!(output_file, inspect(DataStorage.get_struct(@database), pretty: true))

    #{:ok, pid} =  File.open("data/game/regional_map_settings.map",[:write, :utf8])

    File.write!(output_file,:erlang.term_to_binary(DataStorage.get_struct(@database)))
    File.write!(output_file <> "map",
      inspect(DataStorage.get_struct(@database), pretty: true,
      printable_limit: :infinity, limit: :infinity))
  end

  #Pattern matching fails if id, or abstract don't exist..
  #so we need to manually get the data
  #Map.Take is not what we're searching for either..
  def handle_object(object) do
    {id, type, abstract} = { object["id"], object["type"], object["abstract"]}

    #IO.inspect object
    cond do
      !is_nil(id) ->
        create_category_for_type(type, %{})
        DataStorage.add(@database,[type,id], object)
      !is_nil(abstract) ->
        create_category_for_type(type, %{})
        DataStorage.add(@database,[type,abstract], object)
      type == "uncraft" ->
        DataStorage.add(@database,[type, object["result"]], object)
      true ->
        create_category_for_type(type, [])
        DataStorage.append(@database,type,object)
    end

    if !is_nil(object["name"]) do
        key = if(!is_nil(id), do: id, else: abstract)
        DataStorage.add(@database,["names",key],object["name"])
    end
  end
  #Used for reverse searching when the user types certain names
  #The downside is that the user is more likely to mistype so we need to
  #Use enum find
#  DataStorage.add(@database,["name_to_id",object["name"]],key)

  def create_category_for_type(type, empty_struct_type) do
    if !DataStorage.exists(@database,type) do
    #   Logger.debug "Creating a new type #{type}"
       DataStorage.set(@database, type, empty_struct_type )
    end
  end

  def get_all_keys_count(database) do
    Map.keys(database) |> Enum.each(fn (x) ->
      data = Map.get(database,x)
      if !is_list(data) do
        keys = data |> Map.keys() |> Enum.count
        IO.puts "#{x} has #{keys} keys"
      else
        keys = data |> Enum.count
        IO.puts "#{x} has #{keys} items in it's list"
      end

     end)
  end

  @doc  """
  Gets the name from the database for a certain key..
  """
  def get_name(key) do

  end
  @doc  """
    Goes over all the files in the json folder and transforms each one
    into elixir data structures (lists, keys,maps)
    Then saves the output to files in the data_folder.

    TODO file which stores a sha1 hash of all JSON files
    if something has changed, go over the changed files
    reloading the data
  """
  def convert_all_json_to_elixir_data_file(json_folder, data_folder) do
    #{:ok, pid} =  File.open("data/game/regional_map_settings.map",[:write, :utf8])
    #File.write!("data/game/regional_map_settings.map",inspect(city_data, pretty: true))
    #File.write!("data/game/regional_map_settings.term",:erlang.term_to_binary(city_data))
  end
end