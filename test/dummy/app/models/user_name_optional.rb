class UserNameOptional < ActiveRecord::Base

  acts_as_user optional: true
end
