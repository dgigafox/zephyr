import Zephyr.Definition

definition(:global_users)

definition :global_platforms do
  relation(:administrator, [:global_users])
  permission(:super_admin, :administrator)
end

definition :global_organizations do
  relation(:platform, [:global_platforms])
  permission(:admin, :platform > :super_admin)
end

definition :global_resources do
  relation(:owner, [:global_users, :global_organizations])
  permission(:admin, :owner + (:owner > :admin))
end
