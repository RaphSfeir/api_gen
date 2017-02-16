defmodule <%= app_module %>.Repo do
  use Ecto.Repo, otp_app: :<%= app_name %><%= if pagination do %>
  use Scrivener, page_size: 25, max_page_size: 50<% end %>
end
