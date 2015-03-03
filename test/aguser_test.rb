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

    assert NamespacedUser.new(WORKING_USER_PARAMS.merge({namespace: 0})).save
    assert NamespacedUser.new(WORKING_USER_PARAMS.merge({namespace: 1})).save
    assert_not NamespacedUser.new(WORKING_USER_PARAMS.merge({namespace: 0})).save
    assert_not NamespacedUser.new(WORKING_USER_PARAMS.merge({namespace: 1})).save
    assert NamespacedUser.new(WORKING_USER_PARAMS.merge({namespace: 2})).save
  end

  test 'User: scope test with namespace login' do
    user1 = NamespacedUser.create WORKING_USER_PARAMS.merge({namespace: 0})
    user2 = NamespacedUser.create WORKING_USER_PARAMS.merge({namespace: 1})

    assert_equal user1.id, NamespacedUser.authenticate('test_user', 'testing', namespace: 0).id
    assert_equal user2.id, NamespacedUser.authenticate('test_user', 'testing', namespace: 1).id
  end

  test 'User: test invalid login' do
    User.create WORKING_USER_PARAMS
    assert_not_nil User.authenticate('test_user', 'testing')
    assert_nil User.authenticate('test_user', 'something_else')
  end

  test 'User: test disabled user' do
    user = DisableableUser.create WORKING_USER_PARAMS.merge({disabled: true})
    assert_nil DisableableUser.authenticate('test_user', 'testing')
    user.disabled = false
    user.save!
    assert_not_nil DisableableUser.authenticate('test_user', 'testing')
  end


end
