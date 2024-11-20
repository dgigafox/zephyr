import Zephyr.Definition

definition(:basic_users)

definition :basic_groups do
  relation(:member, [:basic_users])
end

definition :basic_documents do
  relation(:writer, [:basic_users, basic_groups: :member])
  relation(:reader, [:basic_users, basic_groups: :member])
  permission(:write, :writer)
  permission(:read, :reader + :write)
end

defmodule Zephyr.RelationGraph.Basic do
  alias Graph.Edge

  def ast do
    %Zephyr.AST{
      entities: [
        %Zephyr.Entity{
          name: "basic_users",
          relations: [],
          permissions: []
        },
        %Zephyr.Entity{
          name: "basic_groups",
          relations: [%Zephyr.Relation{name: "member", user_types: ["basic_users"]}],
          permissions: []
        },
        %Zephyr.Entity{
          name: "basic_documents",
          relations: [
            %Zephyr.Relation{name: "writer", user_types: ["basic_users", "basic_groups#member"]},
            %Zephyr.Relation{name: "reader", user_types: ["basic_users", "basic_groups#member"]}
          ],
          permissions: [
            %Zephyr.Permission{name: "write", expr: "writer"},
            %Zephyr.Permission{
              name: "read",
              expr: {:+, nil, ["basic_documents#reader", "basic_documents.write"]}
            }
          ]
        }
      ]
    }
  end

  def graph do
    Graph.new()
    |> Graph.add_edges([
      # basic groups
      Edge.new({:definition, :basic_groups}, {:relation, :member}),
      Edge.new({:relation, :member}, {:definition, :basic_users}),

      # basic documents

      # relation writer
      Edge.new({:definition, :basic_documents}, {:relation, :writer}),
      Edge.new({:relation, :writer}, {:definition, :basic_users}),
      Edge.new({:relation, :writer}, {:definition, :basic_groups}),
      Edge.new({:definition, :basic_groups}, {:relation, :member}),

      # relation reader
      Edge.new({:definition, :basic_documents}, {:relation, :reader}),
      Edge.new({:relation, :reader}, {:definition, :basic_users}),
      Edge.new({:relation, :reader}, {:definition, :basic_groups}),
      Edge.new({:definition, :basic_groups}, {:relation, :member}),

      # permissions
      Edge.new({:permission, :write}, {:relation, :writer}),
      Edge.new({:permission, :read}, {:operator, :+}),
      Edge.new({:operator, :+}, {:relation, :reader}),
      Edge.new({:operator, :+}, {:permission, :write})
    ])
  end
end
