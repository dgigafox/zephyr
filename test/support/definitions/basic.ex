import Zephyr.Definition

definition(:basic_users)

definition :basic_groups do
  relation(:member, :basic_users)
end

definition :basic_documents do
  relation(:writer, :basic_users + (:basic_groups > :member))
  relation(:reader, :basic_users + (:basic_groups > :member))
  permission(:write, :writer)
  permission(:read, :reader + :write)
end
