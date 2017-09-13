defmodule Bfg do
  @moduledoc """
  Documentation for Bfg.
  """


  def get(domain, port, slug) when is_binary(domain) do
    get(String.to_charlist(domain), port, slug)
  end

  def get(domain, port, slug) when is_binary(slug) do
    get(domain, port, String.to_charlist(slug))
  end

  def get(domain, port, slug) do
    {:ok, pid } = :gun.open(domain, port )
    ref = :gun.get(pid, slug)
    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, _headers} ->  {:ok, _body} = :gun.await_body(pid, ref)
    end

  end

  def get(domain, port, slug, headers) do
    {:ok, pid } = :gun.open(domain, port )
    ref = :gun.get(pid, slug, headers)
    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, headers} ->  {:ok, body} = :gun.await_body(pid, ref)
    end

  end

  def post(domain, port, slug, headers, body, auth) do
    auth_header = basic_auth(auth)
    post(domain, port, slug, [headers | auth_header], body )
  end


  def post(domain, port, slug, headers, body) do
    {:ok, pid } = :gun.open(domain, port)
    ref = :gun.post(pid, slug, headers, body)

    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, headers} -> {:ok, body} = :gun.await_body(pid, ref)
    end
  end


  defp basic_auth({user, password}) do
    auth= Base.encode64("#{user}:#{password}")
    {"Authorization", "Basic " <> auth}
  end

end
