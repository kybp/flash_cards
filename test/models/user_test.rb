require 'test_helper'

class UserTest < SupportTestCase
  def setup
    @valid_email    = 'foo@example.com'
    @valid_password = 'asdfasdf'
  end

  test 'does not save user without email' do
    user = User.new(password: @valid_password)
    assert_not user.save, 'Saved user without email'
  end

  test 'does not save user with invalid email' do
    user = User.new(email: 'foo@', password: @valid_password)
    assert_not user.save, 'Saved user with invalid email'
  end

  test 'does not save user without password' do
    user = User.new(email: @valid_email)
    assert_not user.save, 'Saved user without password'
  end

  test 'does not save user with password < 6 characters' do
    invalid_length   = 5
    invalid_password = @valid_password[0...invalid_length]
    user = User.new(email: @valid_email, password: invalid_password)
    assert_not user.save,
      "Saved user with #{invalid_length} character password"
  end

  test 'saves user with email and password' do
    user = User.new(email: @valid_email, password: @valid_password)
    assert user.save!, 'Did not save valid user'
  end

  test 'does not save user with duplicate email' do
    User.create!(email: @valid_email, password: @valid_password)
    user = User.new(email: @valid_email, password: "#{@valid_password}123")
    assert_not user.save, 'Saved user with duplicate email'
  end

  test 'saves user with duplicate password' do
    User.create!(email: @valid_email, password: @valid_password)
    user = User.new(email: "123#{@valid_email}", password: @valid_password)
    assert user.save, 'Did not save user with duplicate password'
  end
end
