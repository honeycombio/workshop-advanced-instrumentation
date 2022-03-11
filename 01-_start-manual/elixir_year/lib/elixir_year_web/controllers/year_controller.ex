defmodule ElixirYearWeb.YearController do
  use ElixirYearWeb, :controller

  def get_year do
    years = [2015, 2016, 2017, 2018, 2019, 2020]
    rnd = Enum.random(1..250)
    task = Task.async(fn -> Process.sleep(rnd) end)
    Task.await(task)
    # get a random element from the list of years
    year = Enum.random(years)
  end

  def index(conn, _params) do
    year = get_year()
    render(conn, "index.html", year: year)
  end

end
