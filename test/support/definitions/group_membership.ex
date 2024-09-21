import Zephyr.Definition

definition(:gm_users)

definition :gm_roles do
  relation(:member, :gm_users + (:gm_groups > :membership))
  permission(:allowed, :member)
end

definition :gm_groups do
  relation(:admin, :gm_users)
  relation(:member, :gm_users)
  permission(:membership, :admin + :member)
end
