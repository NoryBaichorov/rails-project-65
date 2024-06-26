# frozen_string_literal: true

require_relative '../../test_helper'

class Web::BulletinsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @archived_bulletin = bulletins(:archived)
    @default_bulletin = bulletins(:draft)
    @under_moderation_bulletin = bulletins(:under_moderation)

    @user = users(:user)
    @user_two = users(:user_two)

    @category = categories(:one)
    @image = fixture_file_upload('test.png', 'image/png')

    @attrs = {
      title: Faker::Movies::HarryPotter.character,
      description: Faker::Lorem.paragraph_by_chars(number: 256),
      category_id: @category.id
    }
  end

  test 'should get index' do
    get bulletins_url
    assert_response :success
  end

  test 'should show bulletin' do
    sign_in @user
    get bulletin_url(@default_bulletin)
    assert_response :success
  end

  test 'should get new' do
    sign_in @user

    get new_bulletin_url
    assert_response :success
  end

  test 'should not get new if unauthorized' do
    get new_bulletin_url

    assert_redirected_to root_url
  end

  test 'should get edit if author' do
    sign_in @user

    get edit_bulletin_url(@default_bulletin)
    assert_response :success
  end

  test 'should not get edit if not author' do
    sign_in @user_two

    get edit_bulletin_url(@default_bulletin)

    assert_redirected_to root_path
  end

  test 'should update bulletin' do
    sign_in @user
    patch bulletin_url(@default_bulletin), params: { bulletin: @attrs }

    @default_bulletin.reload

    assert @default_bulletin.title == @attrs[:title]
    assert @default_bulletin.description == @attrs[:description]
    assert_redirected_to profile_path
  end

  test 'should create bulletin' do
    sign_in @user
    post bulletins_url, params: { bulletin: @attrs.merge(image: @image) }

    new_bulletin = Bulletin.find_by @attrs
    assert_redirected_to bulletin_path(new_bulletin)
  end

  test 'should set state to_moderate' do
    sign_in @user
    patch to_moderate_bulletin_path(@default_bulletin)

    @default_bulletin.reload

    assert @default_bulletin.under_moderation?
    assert_redirected_to profile_path
  end

  test 'should not set state to_moderate if unauthorized' do
    patch to_moderate_bulletin_path(@default_bulletin)

    @default_bulletin.reload

    assert @default_bulletin.draft?
    assert_redirected_to root_path
  end

  test 'should set state archived' do
    sign_in @user
    patch archive_bulletin_path(@default_bulletin)

    @default_bulletin.reload

    assert @default_bulletin.archived?
    assert_redirected_to profile_path
  end

  test 'should not set state archived if unauthorized' do
    patch archive_bulletin_path(@default_bulletin)

    @default_bulletin.reload

    assert @default_bulletin.draft?
    assert_redirected_to root_path
  end
end
