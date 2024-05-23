# frozen_string_literal: true

class Web::Admin::BulletinsController < Web::Admin::ApplicationController
  def index
    @bulletins = Bulletin.all
    params[:active_link] = 'bulletins'

    authorize Bulletin
  end

  def publish
    unless resource_bulletin.may_publish?
      flash[:danger] = t('aasm.failure.publish')
      redirect_back(fallback_location: admin_root_path)
    end and return

    authorize resource_bulletin

    resource_bulletin.publish!

    if resource_bulletin.save
      flash[:primary] = t('aasm.success.publish')
      redirect_back(fallback_location: admin_root_path) # rubocop:disable Style/IdenticalConditionalBranches
    else
      flash[:danger] = t('aasm.failure.publish')
      redirect_back(fallback_location: admin_root_path) # rubocop:disable Style/IdenticalConditionalBranches
    end
  end

  def reject
    unless resource_bulletin.may_reject?
      flash[:danger] = t('aasm.failure.reject')
      redirect_back(fallback_location: admin_root_path)
    end and return

    authorize resource_bulletin

    resource_bulletin.reject!

    if resource_bulletin.save
      flash[:primary] = t('aasm.success.reject')
      redirect_back(fallback_location: admin_root_path) # rubocop:disable Style/IdenticalConditionalBranches
    else
      flash[:danger] = resource_bulletin.errors.full_messages.to_sentence
      redirect_back(fallback_location: admin_root_path) # rubocop:disable Style/IdenticalConditionalBranches
    end
  end

  def archive
    unless resource_bulletin.may_archive?
      flash[:danger] = t('aasm.failure.archive')
      redirect_back(fallback_location: admin_root_path)
    end and return

    authorize resource_bulletin

    resource_bulletin.archive!

    if resource_bulletin.save
      flash[:primary] = t('aasm.success.archive')
      redirect_back(fallback_location: admin_root_path) # rubocop:disable Style/IdenticalConditionalBranches
    else
      flash[:danger] = resource_bulletin.errors.full_messages.to_sentence
      redirect_back(fallback_location: admin_root_path) # rubocop:disable Style/IdenticalConditionalBranches
    end
  end

  private

  def bulletin_params
    params.require(:bulletin).permit(:title,
                                     :description,
                                     :image,
                                     :category_id,
                                     :user_id,
                                     :state)
  end
end
