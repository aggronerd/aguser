class NamespacedUser < ActiveRecord::Base

  acts_as_user scope: [:namespace]
end
