defmodule Bfg do
  @moduledoc """
  Documentation for Bfg.
  """

  def get("http://" <> url) do
    {domain, slug} = parse_url(url)
    get(domain, 80, slug, [])
  end


  def get("https://" <> url) do
    {domain, slug} = parse_url(url)
    get(domain, 443, slug, [])
  end


  def get(domain, port, slug) when is_binary(domain) do
    get(String.to_charlist(domain), port, slug)
  end

  def get(domain, port, slug) when is_binary(slug) do
    get(domain, port, String.to_charlist(slug))
  end

  def get(domain, port, slug) do
    get(domain, port, slug, [])
  end

  def get(domain, port, slug, headers, auth) do
    auth_header = basic_auth(auth)
    get(domain, port, slug, [auth_header | headers])
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
    post(domain, port, slug, [auth_header | headers], body )
  end


  def post(domain, port, slug, headers, body) do
    {:ok, pid } = :gun.open(domain, port)
    ref = :gun.post(pid, slug, headers, body)

    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, headers} -> {:ok, body} = :gun.await_body(pid, ref)
    end
  end

  def delete(domain, port, slug, headers, auth) do
    auth_header = basic_auth(auth)
    delete(domain, port, slug, [auth_header | headers])
  end


  def delete(domain, port, slug, headers) do
    {:ok, pid } = :gun.open(domain, port)
    ref = :gun.delete(pid, slug, headers)

    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, headers} -> {:ok, body} = :gun.await_body(pid, ref)
    end
  end

  def put(domain, port, slug, headers, body, auth) do
    auth_header = basic_auth(auth)
    put(domain, port, slug, [auth_header | headers], body )
  end


  def put(domain, port, slug, headers, body) do
    {:ok, pid } = :gun.open(domain, port)
    ref = :gun.put(pid, slug, headers, body)

    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, headers} -> {:ok, body} = :gun.await_body(pid, ref)
    end
  end

  def options(domain, port, slug, headers, auth) do
    auth_header = basic_auth(auth)
    options(domain, port, slug, [auth_header | headers])
  end


  def options(domain, port, slug, headers) do
    {:ok, pid } = :gun.open(domain, port)
    ref = :gun.options(pid, slug, headers)

    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, headers} -> {:ok, body} = :gun.await_body(pid, ref)
    end
  end

  def patch(domain, port, slug, headers, body, auth) do
    auth_header = basic_auth(auth)
    patch(domain, port, slug, [auth_header | headers], body)
  end


  def patch(domain, port, slug, headers, body) do
    {:ok, pid } = :gun.open(domain, port)
    ref = :gun.post(pid, slug, headers, body)

    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, headers} -> {:ok, body} = :gun.await_body(pid, ref)
    end
  end

  def head(domain, port, slug, headers, auth) do
    auth_header = basic_auth(auth)
    head(domain, port, slug, [auth_header | headers] )
  end


  def head(domain, port, slug, headers) do
    {:ok, pid } = :gun.open(domain, port)
    ref = :gun.head(pid, slug, headers)

    case :gun.await(pid, ref) do
      {:response, :fin, _status, _headers} -> :no_data
      {:response, :nofin, _status, headers} -> {:ok, body} = :gun.await_body(pid, ref)
    end
  end



  defp basic_auth({user, password}) do
    auth= Base.encode64("#{user}:#{password}")
    {"Authorization", "Basic " <> auth}
  end

  defp parse_url(url) when is_binary(url) do
    String.split(url, "/")
    |> parse_url()
  end

  defp parse_url([domain | rest ]) do
    [slug] = for item <- rest, do: item <> "/"
    {String.to_charlist(domain), String.to_charlist(slug)}
  end


end
