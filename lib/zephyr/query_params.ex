defmodule Zephyr.QueryParams do
  defstruct [
    :object_namespace,
    :object_key,
    :object_predicate,
    :subject_namespace,
    :subject_key,
    :subject_predicate
  ]
end
