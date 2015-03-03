require 'test_helper'

class AguserTest < ActiveSupport::TestCase

  WORKING_USER_PARAMS = {user_name: 'test_user', password: 'testing', password_confirmation: 'testing'}

  test 'User: creation' do
    user = User.create WORKING_USER_PARAMS
    assert_not_nil user.hashed_password
    assert_not_nil user.salt
  end

  test 'User: no username' do
    user = User.create WORKING_USER_PARAMS.merge(user_name: nil)
    assert_not user.save
  end

  test 'User: wrong password' do
    user = User.create WORKING_USER_PARAMS.merge(password_confirmation: 'something else')
    assert_not user.save
  end

  test 'User: scope test default' do
    user = User.create WORKING_USER_PARAMS
    assert user.save
    user = User.create WORKING_USER_PARAMS
    assert_not user.save
  end

  test 'User: scope test with namespaces' do
    user = NamespacedUser.create WORKING_USER_PARAMS.merge({namespace: 0})
    assert user.save
    user = NamespacedUser.create WORKING_USER_PARAMS.merge({namespace: 1})
    assert user.save
    user = NamespacedUser.create WORKING_USER_PARAMS.merge({namespace: 0})
    assert_not user.save
    user = NamespacedUser.create WORKING_USER_PARAMS.merge({namespace: 1})
    assert_not user.save
    user = NamespacedUser.create WORKING_USER_PARAMS.merge({namespace: 2})
    assert user.save
  end


end
