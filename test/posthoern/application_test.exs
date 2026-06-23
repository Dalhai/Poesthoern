defmodule Posthoern.ApplicationTest do
  use ExUnit.Case, async: true

  test "the OTP application is running" do
    assert {:posthoern, _description, _version} =
             List.keyfind(Application.started_applications(), :posthoern, 0)
  end

  test "the relay supervisor is alive with a live child" do
    pid = Process.whereis(Posthoern.Supervisor)
    assert is_pid(pid)
    assert Process.alive?(pid)

    children = Supervisor.which_children(pid)
    assert Enum.any?(children, fn {_id, child, _type, _modules} -> is_pid(child) end)
  end
end
