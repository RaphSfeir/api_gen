Code.require_file "mix_helper.exs", __DIR__

defmodule Mix.Tasks.Phoenix.Api.NewTest do
  use ExUnit.Case
  import MixHelper

  import ExUnit.CaptureIO
  doctest Mix.Tasks.Phoenix.Api.New

  @app_name "photo_blog"

  setup do
    # The shell asks to install deps.
    # We will politely say not.
    send self(), {:mix_shell_input, :yes?, false}
    :ok
  end

  test "returns the version" do
    Mix.Tasks.Phoenix.Api.New.run(["-v"])
    assert_received {:mix_shell, :info, ["Phoenix v" <> _]}
  end

  test "new without defaults and without Phoenix HTML" do
    in_tmp "new without defaults and without Phoenix HTML", fn ->
      Mix.Tasks.Phoenix.Api.New.run([@app_name, "--no-ecto"])

      # No Ecto
      config = ~r/config :photo_blog, PhotoBlog.Repo,/
      refute File.exists?("photo_blog/lib/photo_blog/repo.ex")

      assert_file "photo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_ecto")

      assert_file "photo_blog/config/config.exs", fn file ->
        refute file =~ "config :phoenix, :generators"
        refute file =~ "ecto_repos:"
      end

      assert_file "photo_blog/config/dev.exs", &refute(&1 =~ config)
      assert_file "photo_blog/config/test.exs", &refute(&1 =~ config)
      assert_file "photo_blog/config/prod.secret.exs", &refute(&1 =~ config)
      assert_file "photo_blog/web/web.ex", &refute(&1 =~ ~r"alias PhotoBlog.Repo")

      assert_file "photo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_html")
      assert_file "photo_blog/mix.exs", &refute(&1 =~ ~r":phoenix_live_reload")
      assert_file "photo_blog/lib/photo_blog/endpoint.ex",
                  &refute(&1 =~ ~r"Phoenix.LiveReloader")
      assert_file "photo_blog/lib/photo_blog/endpoint.ex",
                  &refute(&1 =~ ~r"Phoenix.LiveReloader.Socket")
      assert_file "photo_blog/web/views/error_view.ex", ~r".json"
      assert_file "photo_blog/web/router.ex", &refute(&1 =~ ~r"pipeline :browser")
    end
  end

  test "new with binary_id" do
    in_tmp "new with binary_id", fn ->
      Mix.Tasks.Phoenix.Api.New.run([@app_name, "--binary-id"])

      assert_file "photo_blog/web/web.ex", fn file ->
        assert file =~ ~r/@primary_key {:id, :binary_id, autogenerate: true}/
        assert file =~ ~r/@foreign_key_type :binary_id/
      end

      assert_file "photo_blog/config/config.exs", ~r/binary_id: true/
    end
  end

  test "new with uppercase" do
    in_tmp "new with uppercase", fn ->
      Mix.Tasks.Phoenix.Api.New.run(["photoBlog"])

      assert_file "photoBlog/README.md"

      assert_file "photoBlog/mix.exs", fn file ->
        assert file =~ "app: :photoBlog"
      end

      assert_file "photoBlog/config/dev.exs", fn file ->
        assert file =~ ~r/config :photoBlog, PhotoBlog.Repo,/
        assert file =~ "database: \"photoblog_dev\""
      end
    end
  end

  test "new with path, app and module" do
    in_tmp "new with path, app and module", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--app", @app_name, "--module", "PhoteuxBlog"])

      assert_file "custom_path/.gitignore"
      assert_file "custom_path/mix.exs", ~r/app: :photo_blog/
      assert_file "custom_path/lib/photo_blog/endpoint.ex", ~r/app: :photo_blog/
      assert_file "custom_path/config/config.exs", ~r/namespace: PhoteuxBlog/
      assert_file "custom_path/web/web.ex", ~r/use Phoenix.Controller, namespace: PhoteuxBlog/
    end
  end

  test "new inside umbrella" do
    in_tmp "new inside umbrella", fn ->
      File.write! "mix.exs", umbrella_mixfile_contents()
      File.mkdir! "apps"
      File.cd! "apps", fn ->
        Mix.Tasks.Phoenix.Api.New.run([@app_name])

        assert_file "photo_blog/mix.exs", fn(file) ->
          assert file =~ "deps_path: \"../../deps\""
          assert file =~ "lockfile: \"../../mix.lock\""
        end
      end
    end
  end

  test "new with jsonapi" do
    in_tmp "new with jsonapi", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--jsonapi", "true"])

      assert_file "custom_path/mix.exs", ~r/:ja_serializer/
      assert_file "custom_path/config/config.exs", ["application/vnd.api+json"]
    end
  end

  test "new with pagination" do
    in_tmp "new with pagination", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--pagination", "true"])

      assert_file "custom_path/mix.exs", ~r/:scrivener/
      assert_file "custom_path/lib/custom_path/repo.ex", "use Scrivener"
    end
  end

  test "new with cors" do
    in_tmp "new with cors", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--cors", "true"])

      assert_file "custom_path/mix.exs", ~r/:cors_plug/
      assert_file "custom_path/lib/custom_path/endpoint.ex", "plug CORSPlug"
    end
  end

  test "new with sentry" do
    in_tmp "new with sentry", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--errorstracking", "sentry"])

      assert_file "custom_path/mix.exs", ~r/:sentry/
      assert_file "custom_path/config/config.exs", "config :sentry"
    end
  end

  test "new with rollbar" do
    in_tmp "new with rollbar", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--errorstracking", "rollbar"])

      assert_file "custom_path/mix.exs", ~r/:rollbax/
      assert_file "custom_path/config/config.exs", "config :rollbax"
    end
  end

  test "new with mysql adapter" do
    in_tmp "new with mysql adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--database", "mysql"])

      assert_file "custom_path/mix.exs", ~r/:mariaex/
      assert_file "custom_path/config/dev.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]
      assert_file "custom_path/config/test.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]
      assert_file "custom_path/config/prod.secret.exs", [~r/Ecto.Adapters.MySQL/, ~r/username: "root"/, ~r/password: ""/]

      assert_file "custom_path/test/support/conn_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path/test/support/channel_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path/test/support/model_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
    end
  end

  test "new with tds adapter" do
    in_tmp "new with tds adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--database", "mssql"])

      assert_file "custom_path/mix.exs", ~r/:tds_ecto/
      assert_file "custom_path/config/dev.exs", ~r/Tds.Ecto/
      assert_file "custom_path/config/test.exs", ~r/Tds.Ecto/
      assert_file "custom_path/config/prod.secret.exs", ~r/Tds.Ecto/

      assert_file "custom_path/test/support/conn_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path/test/support/channel_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
      assert_file "custom_path/test/support/model_case.ex", "Ecto.Adapters.SQL.Sandbox.mode"
    end
  end

  test "new with mongodb adapter" do
    in_tmp "new with mongodb adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      Mix.Tasks.Phoenix.Api.New.run([project_path, "--database", "mongodb"])

      assert_file "custom_path/mix.exs", ~r/:mongodb_ecto/

      assert_file "custom_path/config/dev.exs", ~r/Mongo.Ecto/
      assert_file "custom_path/config/test.exs", [~r/Mongo.Ecto/, ~r/pool_size: 1/]
      assert_file "custom_path/config/prod.secret.exs", ~r/Mongo.Ecto/

      assert_file "custom_path/web/web.ex", fn file ->
        assert file =~ ~r/@primary_key {:id, :binary_id, autogenerate: true}/
        assert file =~ ~r/@foreign_key_type :binary_id/
      end

      assert_file "custom_path/test/test_helper.exs", fn file ->
        refute file =~ ~r/Ecto.Adapters.SQL/
      end

      assert_file "custom_path/test/support/conn_case.ex", "Mongo.Ecto.truncate"
      assert_file "custom_path/test/support/model_case.ex", "Mongo.Ecto.truncate"
      assert_file "custom_path/test/support/channel_case.ex", "Mongo.Ecto.truncate"

      assert_file "custom_path/config/config.exs", fn file ->
        assert file =~ ~r/binary_id: true/
        assert file =~ ~r/migration: false/
        assert file =~ ~r/sample_binary_id: "111111111111111111111111"/
      end
    end
  end

  test "new with invalid database adapter" do
    in_tmp "new with invalid database adapter", fn ->
      project_path = Path.join(File.cwd!, "custom_path")
      assert_raise Mix.Error, ~s(Unknown database "invalid"), fn ->
        Mix.Tasks.Phoenix.Api.New.run([project_path, "--database", "invalid"])
      end
    end
  end

  test "new with invalid args" do
    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Phoenix.Api.New.run ["007invalid"]
    end

    assert_raise Mix.Error, ~r"Application name must start with a letter and ", fn ->
      Mix.Tasks.Phoenix.Api.New.run ["valid", "--app", "007invalid"]
    end

    assert_raise Mix.Error, ~r"Module name must be a valid Elixir alias", fn ->
      Mix.Tasks.Phoenix.Api.New.run ["valid", "--module", "not.valid"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phoenix.Api.New.run ["string"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phoenix.Api.New.run ["valid", "--app", "mix"]
    end

    assert_raise Mix.Error, ~r"Module name \w+ is already taken", fn ->
      Mix.Tasks.Phoenix.Api.New.run ["valid", "--module", "String"]
    end
  end

  test "invalid options" do
    assert_raise Mix.Error, ~r/Invalid option: -d/, fn ->
      Mix.Tasks.Phoenix.Api.New.run(["valid", "-database", "mysql"])
    end
  end

  test "new without args" do
    in_tmp "new without args", fn ->

      output =
        capture_io fn ->
          Mix.Tasks.Phoenix.Api.New.run []
        end

      assert output =~ "mix phoenix.new.api"
      assert output =~ "Creates a new Phoenix project with API options and dependencies."
    end
  end
end
