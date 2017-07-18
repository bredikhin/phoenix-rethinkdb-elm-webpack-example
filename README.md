# Rephink: A real-time stack based on Phoenix Framework, RethinkDB, Elm, Webpack

## In search of a perfect stack

I think it's still a popular question that comes up whenever you meet new
people in the industry: so, what's your stack? And you answer with something
like "LAMP", or "MEAN", or some other four-letter word. Every year or so you
get to hear a new one, and other ones take exit (not LAMP though, this one
just can't quit for some reason), and finally you realize that there's no such
thing as the perfect stack. And the same applies to frameworks.

What you figure out instead is that some stacks work really well for a
particular kind of tasks, but can easily fail for some other kinds. It all
depends on the problem you're trying to solve. And that's an essential part
of what system architecture is about.

Thus, there's no such thing as the perfect stack. However, you can get
somewhat close to perfection by keeping in mind your goals and constrains
while choosing the tools. Of course, then the specs can suddenly take a
pivot, and you're going to have to find a way to follow, but that's a
different story.

So, a particular kind of applications we want to talk about today are those
using real-time functionality. Doesn't matter what the exact problem is,
let's just say it all comes down to users needing to receive immediate
feedback during the application interactions operating on some common
state, which is a fairly popular situation nowadays.

Of course, there are already some great tools for it out there, and the first
thing that comes to mind is, obviously,
[WebSocket Protocol](https://en.wikipedia.org/wiki/WebSocket), which we'll be
using as well. If you look at some of its most popular implementations that
were out there during the last years, a lot of them have their server side
written in Node.js (which somewhat convenient since the client side is almost
always in JavaScript). This includes [Socket.io](https://socket.io) /
[Engine.io](https://github.com/socketio/engine.io),
[Sockjs](https://github.com/sockjs/sockjs-client) and based on it
[Meteor.js](https://www.meteor.com). The latter, in fact, is one of the most
impressive platforms for the real-time applications, and I'd even go further
and say it's one of the best for prototyping.

However, if you want something more robust and scalable (either for no
particular reason, or you're just done with prototyping and have some
indisputable needs that require scalability), you could try something else.

What we're going to describe here is a real-time stack based on [Phoenix
Framework](http://www.phoenixframework.org) (written in
[Elixir](http://elixir-lang.org) language) and
[RethinkDB](http://rethinkdb.com) (which is a scalable JSON database with
built-in real-time features). In order to move even further from JavaScript,
we'll also try something different for our client-side:
[Elm](http://elm-lang.org) is a functional language that compiles to
JavaScript while providing some amazing performance and enhanced development
efficiency.

So, this guide is essentially about making it all working together in an
extremely innovative example of an application which is a todo list.

## Todo list

Now, before you go ahead with booing, I admit that a todo list application
is probably the most distressed kind of a Web application example, but
in my defense there are certain advantages in using it, like the fact that
you don't need to reinvent the specs or a variety of benchmarks available
out there. Besides, I honestly believe that despite the fact that there
are loads of todo list apps out there, no one still got this thing totally
right (that's in case you're looking for a business opportunity 😁 ).

## Install Elixir and Phoenix

Elixir is a dynamic functional language leveraging 30 years of existence
of Erlang and combining it with amazing Ruby-like syntax. If you're like
me and appreciated the natural beauty of a good script written in Ruby,
you're going to love Elixir, since on top of that awesome syntax it doesn't
have those performance / scalability issues (can I just add `rvm` and
all the dependency management problems here?) that might have been making
your experience with Ruby more painful than it needed to be.

I bet you're intrigued already, so let's go ahead and install this thing.

The [installation guide](http://elixir-lang.org/install.html) on the
[Elixir website](http://elixir-lang.org) contains pretty much everything
you need to install it. If you're on Mac, I'd recommend going with
[Homebrew](https://brew.sh): you can just type `brew update && brew install
elixir` and relax. Otherwise, just pick a guide for your OS and you should
be fine.

The version we'll be using here is v1.4, which is the latest at the time of
writing.

Now that Elixir is installed, let's proceed with Phoenix.

[Phoenix](http://phoenixframework.org) is a productive, reliable and fast
Web application framework for Elixir language. Let's mention right away that
it's very different from [Ruby on Rails](http://rubyonrails.org) in both its
core and details; however, they do share some values (some API patterns and
principles are borrowed from Rails, for example), and one can say that Phoenix
is for the Elixir community the same thing Rails is for the Ruby one: the
framework.

By this point you should already have both Erlang and Elixir installed,
so you can start reading Phoenix installation guide from the [Phoenix
section](http://www.phoenixframework.org/docs/installation#section-phoenix).
Note that the guide also includes a section on installing Node.js (which
we're going to need to work later with Elm anyway, so go ahead and install it)
and a section on PostgreSQL (which you can safely skip, since we'll be
using RethinkDB instead). Also, you can easily reply 'no' to the question
about installing the dependencies, since we won't be needing the default
JavaScript dependencies Phoenix comes with.

The version of Phoenix described in this article is v1.3. Most of the stuff
should easily work with v1.2 as well, but v1.3 introduces some structural
changes, see the
[upgrade guide](https://gist.github.com/chrismccord/71ab10d433c98b714b75c886eff17357)
for details.

## Install RethinkDB

Installing RethinkDB is pretty simple: just follow the instructions for your
particular OS from their [installation
page](https://rethinkdb.com/docs/install/).

If you're on a Mac, the easiest way is probably to use Homebrew again:

```
brew update && brew install rethinkdb
```

Once it's done and the RethinkDB server is up and running, go to
http://localhost:8080 and make sure you can access the administrative console
(which automatically comes with the RethinkDB server).

It's all set? Let's go ahead and create our application then.

## Create a new Phoenix application

Following Rails' traditions, Phoenix comes with a bunch of CLI generators,
of which the main is the one creating a new project. So, generating a new
application is fairly simple:

```
mix phx.new rephink
```

That is it, if you `cd rephink && ls`, you'll be able to see your brand new
application structure created by Phoenix for you. Beautiful, isn't it? Don't
forget to `git init` at this point in case you want to version control your
steps.

## Add RethinkDB Ecto adapter and create your database

Ecto is an amazingly simple and useful database layer containing migration
engine and a DSL for writing queries. Phoenix uses it by default (although
one could easily change that by adding `--no-ecto` option to the command
that generates your new Phoenix project).

Now, as great as Ecto is, we don't have to use it for this particular project,
since RethinkDB queries we'll be running are a little bit different from,
let's say, PostgreSQL ones. However, schema definition and migrations
can still make Ecto extremely useful. Besides, having this amazing [Ecto
adapter for RethinkDB](https://github.com/almightycouch/rethinkdb_ecto) lets
use Ecto with RethinkDB without adding a lot of extra code.

So, let's set it up. Add `rethinkdb_ecto` to your dependencies in `mix.exs`:

```elixir
def deps do
  [...
   {:cowboy, "~> 1.0"},
   {:rethinkdb_ecto, "~> 0.6.2"}]
end
```

You can also remove `postgrex` since we're not going to use it.

Add a couple of lines to `config/config.exs` to specify the adapter:

```elixir
config :rephink, Rephink.Repo,
  adapter: RethinkDB.Ecto
```

And update the database configuration in the environment config file (i.e.
`config/dev.exs`, since we're just trying it all out for now):

```elixir
config :rephink, Rephink.Repo,
  [port: 28015, host: "localhost", database: "rephink", db: "rephink"]
```

Notice the presence of both `database` and `db` keys in that keyword list.
The reason we need them both is that we're going to use this configuration with
two different libraries (`rethinkdb` and `rethinkdb-ecto`) and they have
different opinions on the right name for the database key.

Don't forget to `mix deps.get` and resolve dependencies if needed, then try
running `mix ecto.create`. If you got it all right this should create a
database called "rephink" which should show up in the tables section
of the RethinkDB admin console (http://localhost:8080/ by default).

## Create the database table

Since it's a pretty basic example aiming at giving you an overall
impression only, we're just going to use one table, the one that'll store
our todos.

All we need to do is to use a schema generator provided by Phoenix:

```
mix phx.gen.schema Rephink.Todo todos task:string completed:boolean
```

This will create a schema and a migration for a new table that will
store our todos. We chose the simplest structure since, once again, our
application won't include any fancy todo fields (related to scheduling,
etc.), nor it will have any auth built in. So, we can get away with
using only two fields, but at the same time it should be able to get
us an acceptable overview of the basics.

Finally, we need to run the migration using `mix ecto.migrate`, and
this will create a new table in our database (along with the
`schema_migrations` table used to track the migrations).

## Install Elm

In order to install Elm follow the instructions from
https://guide.elm-lang.org/install.html. And if you're on Mac, once
again, Homebrew is your friend:

```
brew install elm
```

Throughout this post we'll assume using v0.18 of Elm.

## Install Webpack and make it work with Phoenix

Phoenix comes with [Brunch](http://brunch.io) configuration for managing
application assets, but we're going to use Webpack instead, so the first thing
we should do is removing the Brunch configuration file:
`rm assets/brunch-config.js` (here and elsewhere all the paths are relative to
the project root folder). Let's remove Brunch dependencies from
`assets/package.json` as well:

```json
{
  "repository": {},
  "license": "MIT",
  "scripts": {
    "deploy": "brunch build --production",
    "watch": "brunch watch --stdin"
  },
  "dependencies": {
    "phoenix": "file:../deps/phoenix",
    "phoenix_html": "file:../deps/phoenix_html"
  },
  "devDependencies": {
  }
}
```

Next, let's install Webpack (we're using v2.3.3 here):

```
cd assets && npm install --save-dev webpack
```

Once it's done, create `assets/webpack.config.js` with the following content:

```json
module.exports = {
  entry: './js/app.js',
  output: {
    path: require('path').resolve('./../priv/static'),
    filename: 'js/app.js'
  }
};
```

Now we need to add a command that will be used to run Webpack. Open
`assets/package.json` again and edit the line corresponding to the `watch`
script. Also, since we're already here, let's replace the deployment script
as well in order to get rid of any mentioning of Brunch:

```json
{
  ...
  "scripts": {
    "deploy": "webpack -p",
    "watch": "webpack --watch-stdin --progress --color"
  }
  ...
}
```

Next, update `config/dev.exs` to replace the `watchers` line under
`Rephink.Web.Endpoint` configuration with the following

```elixir
...
watchers: [npm: ["run", "watch", cd: Path.expand("../assets", __DIR__)]]
...
```

Now, since Phoenix uses ES2015 syntax for its JavaScript files, we're going to
have to ask Webpack to transpile it for us.

Let's start with installing Babel:

```
cd assets && npm i babel-loader babel-core babel-preset-es2015 --save-dev
```

Configuration is pretty straightforward, all you need to do is to add the
following lines to your `assets/webpack.config.js`:

```javascript
module.exports = {
  ...

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        options: {
          presets: ['es2015']
        }
      }
    ]
  }
}
```

The only thing that's left to do is to tell Webpack how to resolve module
requests (where to look for imports), which is as simple as adding
`var resolve = require('path').resolve;` at the beginning of your
`assets/webpack.config.js` and the following lines in the `module.exports`:

```javascript
module.exports = {
  ...

  resolve: {
    modules: ['node_modules', resolve('./../deps')]
  }
}
```

With this done you can go ahead and install your JavaScript dependencies
via `cd assets && npm i`, then start the Phoenix server from the root
folder of your application with `mix phx.server`. Once it's up, you should be
able to see Webpack successfully compiling your JavaScript.

What about CSS, you ask? Ok, let's make Webpack compile CSS as well:

```
cd assets && npm i css-loader style-loader extract-text-webpack-plugin --save-dev
```

Update `assets/webpack.config.js` to include the CSS source, the loader and
the plugin extracting CSS in a separate file:

```javascript
...
var ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  entry: ['./js/app.js', './css/app.css'],
  ...
  module: {
    rules: [
      ...,
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract({fallback: 'style-loader', use: 'css-loader'})
      }
    ]
  },
  plugins: [
    new ExtractTextPlugin('css/app.css')
  ],
  ...
```

Finally, we need to move our static assets from `assets/static` to `priv/static`,
and there's a Webpack plugin that takes care of it:

```
cd assets && npm i --save-dev copy-webpack-plugin
```

And, of course, add it to the Webpack configuration:

```javascript
...
var CopyWebpackPlugin = require('copy-webpack-plugin');

module.exports = {
  ...
  plugins: [
    ...,
    new CopyWebpackPlugin([{from: './static'}])
  ]
  ...
```

## Add TodoMVC

Since this guide doesn't aim at teaching specifics of Elm programming from
the very start, we'll use an example of the TodoMVC application provided by
the Elm creator Evan Czaplicki (to whom go my sincere apologies for what I'm
going to do with his beautiful code further) as the template for our frontend:

```
git clone git@github.com:evancz/elm-todomvc.git elm && cd elm && rm -rf .git
```

This is essentially the equivalent of exporting only the default branch from
the original Git repository, which makes sense for us, especially in case
you're version-controlling the whole repository.

Now, how do we make our Phoenix server and Webpack compile Elm and show us the
Elm application? This part doesn't get too complicated either. First, let's
install Elm loader for Webpack:

```
cd assets && npm i --save-dev elm-webpack-loader
```

Next, in order to configure it to compile the Elm code, update you Webpack
configuration with the following lines:

```javascript
...
module.exports = {
  ...
  module: {
    rules: [
      ...,
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        loader:  'elm-webpack-loader?cwd=' + resolve('./../elm')
      }
    ]
  },
  ...
```

Once it's done, we're ready to integrate that TodoMVC example with our Phoenix
setup. First, let's just move the CSS file bundled with the example to the
appropriate location, so Webpack could pick it up:

```
mv elm/style.css assets/css/app.css
```

Next thing we need to do is to insert our Elm application into our homepage
generated by Phoenix. Starting with JavaScript, update `assets/js/app.js` and
add the following lines (taken mostly from `elm/index.html` and adapted for
ES2015):

```javascript
let Elm = require('../../elm/Todo.elm')
let storedState = localStorage.getItem('elm-todo-save')
let startingState = storedState ? JSON.parse(storedState) : null
let todomvc = Elm.Todo.fullscreen(startingState)
todomvc.ports.setStorage.subscribe((state) => {
    localStorage.setItem('elm-todo-save', JSON.stringify(state))
})
```

Note that we're keeping the subscription to local storage here for now just so
we could see the app working, but it's going to be removed once we connect our
Elm code to the database via a Phoenix channel.

Okay, after that piece of JavaScript is copied, you can safely delete
`elm/index.html`, since we've got all we needed out of it.

The last thing to do before we'll be able to test our Elm setup is to clean up
the page template coming with Phoenix by default. It's as simple as emptying
the content of the `body` tag in
`lib/rephink/web/templates/layout/app.html.eex` (except for the `script` tag
that loads our JavaScript):

```html
...
  <body>
    <script src="<%= static_path(@conn, "/js/app.js") %>"></script>
  </body>
...
```

Now, if everything is done right, once you start your Phoenix server with
`mix phx.server`, you should see a fully functional TodoMVC example when
you go to `http://localhost:4000/`. Try entering some tasks, but remember
that the data is being stored in that particular browser, so if you open
the same page in a different one, you'll get an empty list. But we're here
to fix it.

## Create a channel and connect to it using Elm

Phoenix channels are essentially a message passing engine that plays
perfectly with Websockets in order to provide your application with
real-time functionality. Using channels you can send and receive messages
grouped by topics, broadcast to multiple clients, etc.

Let's just go ahead and create a channel, so we could learn it all in
practice:

```
mix phx.gen.channel Todo
```

After that, as the message says, we need to add our channel to the socket
handler in `lib/rephink/web/channels/user_socket.ex`:

```
channel "todo:*", Rephink.Web.TodoChannel
```

Once it's taken care of, let's write our channel module. The generator should
have already created all the necessary functions with example signatures and
bodies, so all we need to do is to open
`lib/rephink/web/channels/todo_channel.ex` and edit it according to our goals:

```elixir
defmodule Rephink.Web.TodoChannel do
  use Rephink.Web, :channel

  def join("todo:list", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("ping", _payload, socket) do
    Rephink.Web.Endpoint.broadcast!(socket.topic, "pong", %{"response" => "pong"})

    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
```

Nothing special so far, we're keeping the standard placeholder for joining /
authorization, but not going to elaborate on it in this post considering for
sake of simplicity that we only have one common task list and everybody can
read and modify it. As for the "ping" message, it's a temporary one, and we'll
use it to make sure our channel can connect to the Elm client side.

Before we go any further, let's strip that local storage functionality that
came with the original app, since we're not going to use it. In `elm/Todo.elm`,
perform the following changes:

1. remove `port` from the first line,

2. remove the line
```
port setStorage : Model -> Cmd msg
```

3. change
```
main : Program (Maybe Model) Model Msg
```
to be
```
main : Program Never Model Msg
```

4. change
```
Html.programWithFlags
```
to
```
Html.program
```

5. change the line
```
         , update = updateWithStorage
```
to
```
         , update = update
```

6. remove `updateWithStorage` declaration and body.

Also, the Elm app initialization in `assets/js/app.js` becomes much simpler:

```javascript
// Elm application
let Elm = require('../../elm/Todo.elm')
let todomvc = Elm.Todo.fullscreen()
```

Okay, now that it's taken care of, let's add the Elm package that will help us
communicate with Phoenix:

```
cd elm && elm package install -y fbonetti/elm-phoenix-socket
```

Next, open `elm/Todo.elm` and add the following to the imports section:

```elixir
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
```

Now we need to add the socket to our application state (aka `Model`):

```elm
type alias Model =
    { entries : List Entry
    , ...
    , socket : Phoenix.Socket.Socket Msg
    }
```

We must also initialize it properly, so `init` combined with `emptyModel`
(which you can safely remove at this point) gives us the following:

```elm
init : ( Model, Cmd Msg )
init =
    let
        channelName = "todo:list"
        channel = Phoenix.Channel.init channelName
            |> Phoenix.Channel.onJoin (always RequestEntries)
        socketInit = Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
            |> Phoenix.Socket.on "pong" channelName ReceiveEntries
        ( socket, cmd ) =
            Phoenix.Socket.join channel socketInit
    in
        { entries = []
        , visibility = "All"
        , field = ""
        , uid = 0
        , socket = socket
        } ! [ Cmd.map SocketMsg cmd ]
```

As you can see, we included socket / channel initialization and request to
join, which in its turn should trigger requesting the todo entries from the
database.

Next stop: we need to add some new messages to our `Msg` type:

```elm
type Msg
    = NoOp
    ...
    | SocketMsg (Phoenix.Socket.Msg Msg)
    | RequestEntries
    | ReceiveEntries Encode.Value
```

The latter requires a new `import` to be added:

```elixir
import Json.Encode as Encode
import Debug exposing (log)
```

(here we've also added Elm's logging function, so we could analyze responses
coming from our Phoenix server).

The first of these messages corresponds to the socket updates, the second one,
`RequestEntries`, will send requests to the server via a Phoenix channel to
fetch a specific set of entries, and finally `ReceiveEntries` defines how to
handle the data we receive.

Now, we should describe how those messages are supposed to be handled within
the `update` function:

```elm
update msg model =
    case msg of
        NoOp ->
...
        SocketMsg msg ->
            let
                ( socket, cmd ) =
                    Phoenix.Socket.update msg model.socket
            in
                { model | socket = socket } ! [ Cmd.map SocketMsg cmd ]

        RequestEntries ->
            let
                push =
                    Phoenix.Push.init "ping" "todo:list"
                        |> Phoenix.Push.onOk ReceiveEntries
                ( socket, cmd ) =
                    Phoenix.Socket.push push model.socket
            in
                { model | socket = socket } ! [ Cmd.map SocketMsg cmd ]

        ReceiveEntries raw ->
            let
                entries = log "Ping" raw
            in
                model ! []
```

Here, for sake of demonstration, we're sending a ping to our Phoenix server
and just logging what's received.

The last addition we need to do is a subscription to our socket: change
the `subscriptions` line in the `main` definition to

```elm
main =
...
        , subscriptions = subscriptions
        }
```

and add the `subscriptions` section at the bottom of the `elm/Todo.elm`:

```elm
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.socket SocketMsg
```

Perfect, let's take it for a spin using `mix phoenix server`. If all is done
properly, you should see `Ping: { response = "pong" }` in the browser console
when you go to http://localhost:4000/ with developer tools open. This means
our Elm application was able to successfully communicate with our server using
a Phoenix channel.

However, as impressive as this ping-pong demonstration is, it's hardly useful
until we somehow combine these results with the main purpose of our todo list
app. So, let's figure out how to do it.

We'll start by fetching a list of todos from the server, and we will use the
same message (we will just call it "todos") to request and receive the current
list. On the server side, change that `handle_in` inside
`lib/rephink/web/channels/todo_channel.ex` to the following:

```elixir
  @table_name "todos"

  def handle_in("todos", _payload, socket) do
    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    Rephink.Web.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end
```

In order for this code to work, you should also:

1. add `import RethinkDB.Query` at the beginning of that file,

2. establish a database connection by creating `lib/rephink/db.ex` with the
following content:

```elixir
defmodule Rephink.DB do
  use RethinkDB.Connection
end
```

3. add it as a worker to the main supervision tree in
`lib/rephink/application.ex`:

```elixir
...
  def start(_type, _args) do
    ...
    children = [
      ...
      # Start your own worker by calling: Rephink.Worker.start_link(arg1, arg2, arg3)
      worker(Rephink.DB, [Application.get_env(:rephink, Rephink.Repo)]),
    ]
    ...
  end
  ...
```

4. make sure your `mix.exs` starts the `rethinkdb` application:

```elixir
...
  def application do
    [mod: {Rephink.Application, []},
     extra_applications: [:logger, :runtime_tools, :rethinkdb]]
  end
...
```

Next, let's take care of the client side. In you `elm/Todo.elm`, start by
replacing message names "ping" and "pong" with "todos":

```elm
...
        socketInit = Phoenix.Socket.init "ws://localhost:4000/socket/websocket"
            |> Phoenix.Socket.on "todos" channelName ReceiveEntries
...
        RequestEntries ->
            let
                push =
                    Phoenix.Push.init "todos" "todo:list"
...
```

At this point we should be able to receive the todo list entries from the
server, but still need to figure out how to update our model.

We will use `ReceiveEntries` message to do it:

```elm
...
        ReceiveEntries raw ->
            let
                decoded =
                    Json.decodeValue
                        ( Json.field "todos"
                            ( Json.list
                                ( Json.map4
                                    Entry
                                    (Json.field "task" Json.string)
                                    (Json.field "completed" Json.bool)
                                    (Json.succeed False)
                                    (Json.field "id" Json.int)
                                )
                            )
                        )
                        raw
            in
                case decoded of
                    Ok entries ->
                        { model | entries = entries } ! []
                    Err error ->
                        model ! []
...
```

Done? Let's try it out. For now we're just going to add some todos manually
via RethinkDB admin which is running on http://localhost:8080 by default. Open
http://localhost:8080/#tables and make sure your database was created and has
*todos* table. Then switch to http://localhost:8080/#dataexplorer and enter the
following:

```javascript
r.db('rephink').table('todos').insert([
  {id: 1, task: "Task 1", completed: false},
  {id: 2, task: "Task 2", completed: false},
  {id: 3, task: "Task 3", completed: false}
])
```

(or, well, any other tasks you have in mind).

Once it's run, `r.db('rephink').table('todos')` should show you that we have
three rows in our table now. And actually, starting your Phoenix server and
opening http://localhost:4000 should also show you your todo list with the
same entries. You can even edit / delete / complete items, the only problem is
that it won't be written to the database. But we'll fix it in a bit.


## Update the database

Let's start with adding new entries. On the server side, we need another
`handle_in` clause in `lib/rephink/web/channels/todo_channel.ex`:

```elixir
...
  def handle_in("insert", %{"todo" => todo}, socket) do
    table(@table_name)
      |> insert(todo)
      |> RethinkDB.run(Rephink.DB)
    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    Rephink.Web.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end
...
```

On the client side, it's a bit more work. First, a little side note: in
this example we'll be using integer row ids, which is not the best idea and
it's not what RethinkDB is using by default. The reason we want it is that
we'd like to keep this example as simple as possible, and the original TodoMVC
example was based on integer ids. With that in mind, let's add a little update
to the model which will get triggered whenever we fetch our entries from the
server:

```elm
...
        ReceiveEntries raw ->
            let
                decoded =
                    ...
                nextId xs = List.foldl (\x y->if x.id > y then x.id else y) 0 xs
            in
                case decoded of
                    Ok entries ->
                        { model | entries = entries, uid = nextId entries } ! []
...
```

This finds the biggest row id in the entries and stores it in the `uid` field.
And it gets extremely handy when we're trying to insert a new record in the
database:

```elm
...
update msg model =
        ...
        Add ->
            let
                payload =
                    Encode.object
                        [ ( "todo", Encode.object
                            [ ("task", Encode.string model.field)
                            , ("id", Encode.int (model.uid + 1))
                            , ("completed", Encode.bool False)
                            ]
                          )
                        ]

                push =
                    Phoenix.Push.init "insert" "todo:list"
                        |> Phoenix.Push.withPayload payload

                ( socket, cmd ) =
                    Phoenix.Socket.push push model.socket
            in
                { model | socket = socket, field = "" }
                    ! [ Cmd.map SocketMsg cmd ]

...
```

Now, once again, using integer ids and generating them on the client is
probably something that can be easily nominated to receive the "Worst Idea
Ever" prize, but for sake of simplicity we'll just assume that every client
gets its entries updated before inserting any new row in the database, and
that there's no race conditions possible. In the real world, of course, the
way to go is to use the UUIDs being generated by RethinkDB by default.

So, with this disclaimer out of the way, run `mix phx.server`, open
http://localhost:4000/ and add a new entry (type something in the input
field and hit `Enter`). You should see your new entry appearing in the list,
and it should be there even once you refresh the page, it's stored in the
database now.

Perfect, let's proceed with updating the existing records then. The flow
is very similar, we're starting by adding a server-side handler to
`lib/rephink/web/channels/todo_channel.ex`:

```elixir
...
  def handle_in("update", %{"todo" => todo}, socket) do
    table(@table_name)
      |> update(todo)
      |> RethinkDB.run(Rephink.DB)
    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    Rephink.Web.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end
...
```

Then, on the client side we're going to be changing the `EditingEntry` message
and adding a new one called `SyncEntry` (which should also be added to the
`Msg` type):

```elm
...
type Msg
    = NoOp
    | SyncEntry Int
...
update msg model =
        ...

        EditingEntry id isEditing ->
            let
                updateEntry t =
                    if t.id == id then
                        { t | editing = isEditing }
                    else
                        t

                focus =
                    Dom.focus ("todo-" ++ toString id)

                (updatedModel, cmd) =
                    if (not isEditing) then
                        update (SyncEntry id) model
                    else
                        (model, Cmd.none)
            in
                { updatedModel | entries = List.map updateEntry updatedModel.entries }
                    ! [ Task.attempt (\_ -> NoOp) focus, cmd ]

        SyncEntry id ->
            let
                edited = List.head (List.filter (\x -> x.id == id) model.entries)
                ( socket, cmd ) =
                    case edited of
                        Nothing -> (model.socket, Cmd.none)
                        Just entry ->
                            let
                                payload =
                                    Encode.object
                                        [ ( "todo", Encode.object
                                            [ ("task", Encode.string entry.description)
                                            , ("id", Encode.int entry.id)
                                            , ("completed", Encode.bool entry.completed)
                                            ]
                                          )
                                        ]

                                push =
                                    Phoenix.Push.init "update" "todo:list"
                                        |> Phoenix.Push.withPayload payload

                          in
                              Phoenix.Socket.push push model.socket
            in
                { model | socket = socket }
                    ! [ Cmd.map SocketMsg cmd ]
...
```

What's happening here is we're sending our updated entry to the server
(via `SyncEntry`) whenever we finish editing (receiving `EditingEntry` with
`isEditing` equal to `False`). This doesn't let us handle the completion of
tasks though, so we also need to update `Check` and `CheckAll` handlers:

```elm
...
update msg model =
        ...

        Check id isComplete ->
            let
                updateEntry t =
                    if t.id == id then
                        { t | completed = isComplete }
                    else
                        t
                updatedModel = { model | entries = List.map updateEntry model.entries }
            in
                update (SyncEntry id) updatedModel

        CheckAll isCompleted ->
            let
                updateEntry t =
                    { t | completed = isCompleted }
                allCheckedModel = { model | entries = List.map updateEntry model.entries }
                syncEntry t (model, cmdList) =
                    let
                        (updatedModel, newCmd) = update (SyncEntry t.id) model
                    in
                        (updatedModel, List.append cmdList [ newCmd ])
                (updatedModel, cmdList) = List.foldr
                    syncEntry (allCheckedModel, [])
                    allCheckedModel.entries
            in
                updatedModel ! cmdList
...
```

As you might have noticed, the last update handler is extremely inefficient
since it sends a number of messages essentially equal to the number of our
todo entries being checked. Instead, we should have introduced a command for
bulk update of a list of entries, but for sake of simplicity we're leaving it
as a refactoring exercise to the reader (same applies to the updated
`DeleteComplete` handler below).

Now, the only thing that's left to handle is removing entries, which consists
of a server and a client side as well. Let's start with the server side and
add removal clause to the `lib/rephink/web/channels/todo_channel.ex`:

```elixir
  def handle_in("delete", %{"todo" => todo}, socket) do
    table(@table_name)
      |> get(todo["id"])
      |> delete()
      |> RethinkDB.run(Rephink.DB)
    %{data: todos} = table(@table_name) |> RethinkDB.run(Rephink.DB)
    Rephink.Web.Endpoint.broadcast!(socket.topic, "todos", %{todos: todos})

    {:noreply, socket}
  end
```

As for the client side code for entry removal, it looks like this:

```elm
...
update msg model =
        ...

        Delete id ->
            let
                deleted = List.head (List.filter (\x -> x.id == id) model.entries)
                ( socket, cmd ) =
                    case deleted of
                        Nothing -> (model.socket, Cmd.none)
                        Just entry ->
                            let
                                payload =
                                    Encode.object
                                        [ ( "todo", Encode.object
                                            [ ("id", Encode.int entry.id) ]
                                          )
                                        ]

                                push =
                                    Phoenix.Push.init "delete" "todo:list"
                                        |> Phoenix.Push.withPayload payload

                          in
                              Phoenix.Socket.push push model.socket
            in
                { model | socket = socket }
                    ! [ Cmd.map SocketMsg cmd ]

        DeleteComplete ->
            let
                deleteEntry t (model, cmdList) =
                    let
                        (updatedModel, newCmd) = update (Delete t.id) model
                    in
                        (updatedModel, List.append cmdList [ newCmd ])
                (updatedModel, cmdList) = List.foldr
                    deleteEntry (model, [])
                    (List.filter .completed model.entries)
            in
                updatedModel ! cmdList
...
```

With this in place we should have fully functional (albeit not perfect in
terms of performance) todo list example in Elm connected to RethinkDB
database via Phoenix backend. But wait, is there anything special about it?
Was it even worth it? It will, in just a couple of minutes.

## Subscribe to the changes

Changefeeds are arguably one of the most attractive features of RethinkDB.
Remember Meteor.js? All the performance and compatibility issues aside, it
was kind of cool getting real-time updates for free, and it even was (almost)
scalable via MongoDB oplog tailing. So, RethinkDB changefeeds let you
essentially get the same functionality, once again, for free. Well, almost.

Changefeeds allow you to subscribe and receive changes in the results of
virtually any RethinkDB query. You can easily track a query, a table or even
a single document using this functionality. And given the fact that the
clustering, replication and sharding are built-in, you don't have to worry
about scalability for a while in case you had some (most probably premature)
concerns about it.

So, how do we arrange it? Let's say, we want to sync our todo list across
multiple devices and get real-time pushes whenever we edit it on one of them?
Let's see.

First, we're going to be using a dedicated library to deal with the
changefeeds: https://github.com/hamiltop/rethinkdb_changefeed. Configuration
is pretty straightforward: we just need to add
`{:rethinkdb_changefeed, "~> 0.0.1"}` to the list of the dependencies and
start `:rethinkdb_changefeed` with all the other `extra_applications` in
the `application` in our `mix.exs`. Don't forget to run `mix deps.get` to
fetch the library.

Next, let's create `lib/rephink/changefeed.ex` containing the following

```elixir
defmodule Rephink.Changefeed do
  use RethinkDB.Changefeed
  import RethinkDB.Query

  @table_name "todos"
  @topic "todo:list"

  def start_link(db, gen_server_opts \\ [name: Rephink.Changefeed]) do
    RethinkDB.Changefeed.start_link(__MODULE__, db, gen_server_opts)
  end

  def init(db) do
    query = table(@table_name)
    %{data: data} = RethinkDB.run(query, db)
    todos = Enum.map(data, fn (x) ->
      {x["id"], x}
    end) |> Enum.into(%{})

    {:subscribe, changes(query), db, {db, todos}}
  end

  def handle_update(data, {db, todos}) do
    todos = Enum.reduce(data, todos, fn
      %{"new_val" => nv, "old_val" => ov}, p ->
        case nv do
          nil ->
            Map.delete(p, ov["id"])
          %{"id" => id} ->
            Map.put(p, id, nv)
        end
    end)
    Rephink.Web.Endpoint.broadcast!(@topic, @table_name, %{todos: Map.values(todos)})

    {:next, {db, todos}}
  end
end
```

What we got ourselves here is essentially a
[`GenServer`](https://hexdocs.pm/elixir/GenServer.html) that holds the current
list of todos as its state and updates it whenever the database subscription
receives change notifications.

So, all we need to do now with this changefeed process is to add it to our
supervision tree in `lib/rephink/application.ex`:

```elixir
...
  def start(_type, _args) do
    ...
    children = [
      ...
      worker(Rephink.Changefeed, [Rephink.DB])
    ]
    ...
  end
...
```

Note that the update handler also broadcasts the updated todo list, which
means that if you start your Phoenix server now and, for example, open the
application in two browser tabs simultaneously then updating something in one
tab will automatically update the other one. Yes, do see it for yourself.

It's interesting that in this particular case when we only have one topic common
for all the users, simple broadcasting to the channel on any update would do the
trick, however in more elaborate cases different users should be subscribed to
receive different set of entries. Besides, the database content can also be
modified via other applications / tools (you can try updating one of your
entries directly using RethinkDB admin console at http://localhost:8080/, for
example), and that's where our database subscription really shines.

Although at this point we're basically reached our goal, let's apply one final
touch in order to improve the structure of our code. We're going to move the
database interactions out of our channel code, which will let us use our
changefeed process' state to store the current todos and only hit the database
when it's really needed. In order to do that, let's add the following to our
`lib/rephink/changefeed.ex`:

```elixir
...
  def handle_call(:todos, _from, {db, todos}) do
    Rephink.Web.Endpoint.broadcast!(@topic, @table_name, %{todos: Map.values(todos)})

    {:reply, Map.values(todos), {db, todos}}
  end

  def handle_call({:insert, todo}, _from, {db, todos}) do
    table(@table_name)
      |> insert(todo)
      |> RethinkDB.run(db)

    {:reply, Map.values(todos), {db, todos}}
  end

  def handle_call({:update, todo}, _from, {db, todos}) do
    table(@table_name)
      |> update(todo)
      |> RethinkDB.run(db)

    {:reply, Map.values(todos), {db, todos}}
  end

  def handle_call({:delete, todo}, _from, {db, todos}) do
    table(@table_name)
      |> filter(todo)
      |> delete()
      |> RethinkDB.run(db)

    {:reply, Map.values(todos), {db, todos}}
  end
...
```

This will allow us to simplify
`rephink/lib/rephink/web/channels/todo_channel.ex` (let's just provide the
complete listing here):

```elixir
defmodule Rephink.Web.TodoChannel do
  use Rephink.Web, :channel
  alias RethinkDB.Changefeed

  def join("todo:list", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("todos", _payload, socket) do
    Changefeed.call(Rephink.Changefeed, :todos)

    {:noreply, socket}
  end

  def handle_in("insert", %{"todo" => todo}, socket) do
    Changefeed.call(Rephink.Changefeed, {:insert, todo})

    {:noreply, socket}
  end

  def handle_in("update", %{"todo" => todo}, socket) do
    Changefeed.call(Rephink.Changefeed, {:update, todo})

    {:noreply, socket}
  end

  def handle_in("delete", %{"todo" => todo}, socket) do
    Changefeed.call(Rephink.Changefeed, {:delete, todo})

    {:noreply, socket}
  end

  defp authorized?(_payload) do
    true
  end
end
```

As you can see here, all the database queries were moved out of the channel
code and replaced with the server calls, and the changefeed code holds all the
data we need in its state and updates it whenever the database gets updated.

## Conclusion

Thus, what we described here is essentially a real-time platform that can be
used to create applications for multiple devices with real-time update and
syncing capabilities. So what, you may say, it's so 2012. Well, yes and no:
this time it's faster, more reliable, robust and well-structured. Besides, the
tools we're using now have built-in scalability features, so if at some point
you're going to feel like you need to scale horizontally, you can easily
leverage the power of distributed Elixir and RethinkDB clustering.

Obviously, it's a somewhat artificial example based on multiple assumptions
that are hardly applicable to real life situations, but the purpose of it is
mostly to show how these amazing tools can be connected and work together. I
really hope I managed at least to get you interested. And of course, your
constructive feedback is always welcome.

## Credits

- http://elixir-lang.org
- http://www.phoenixframework.org
- https://www.rethinkdb.com
- http://elm-lang.org
- https://webpack.js.org
- https://github.com/evancz/elm-todomvc
- https://github.com/hamiltop/rethinkdb-elixir
- https://github.com/hamiltop/rethinkdb_changefeed
- https://github.com/almightycouch/rethinkdb_ecto

## License

[The MIT License](http://opensource.org/licenses/MIT)

Copyright (c) 2017 [Ruslan Bredikhin](http://ruslanbredikhin.com/)
