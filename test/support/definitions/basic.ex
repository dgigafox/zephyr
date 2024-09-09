import Zephyr.Definition

definition(:basic_users)

definition :basic_groups do
  relation(:member, [:user, :basic_groups > :member])
end

definition :basic_documents do
  relation(:writer, [:user, :basic_groups > :member])
  relation(:reader, [:user, :basic_groups > :member])
  permission(:write, :writer)
  permission(:read, :reader + :write)
end
