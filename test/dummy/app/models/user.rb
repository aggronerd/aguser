class User < ActiveRecord::Base

  acts_as_user scope: []
end
