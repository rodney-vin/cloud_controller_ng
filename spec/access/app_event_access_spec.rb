require 'spec_helper'

module VCAP::CloudController::Models
  describe AppEventAccess, type: :access do
    subject(:access) { AppEventAccess.new(double(:context, user: user, roles: roles)) }
    let(:user) { VCAP::CloudController::Models::User.make }
    let(:roles) { double(:roles, :admin? => false, :none? => false, :present? => true) }
    let(:org) { VCAP::CloudController::Models::Organization.make }
    let(:space) { VCAP::CloudController::Models::Space.make(:organization => org) }
    let(:app) { VCAP::CloudController::Models::App.make(:space => space) }
    let(:object) { VCAP::CloudController::Models::AppEvent.make(:app => app) }

    it_should_behave_like :admin_full_access

    context 'organization manager' do
      before { org.add_manager(user) }
      it_behaves_like :read_only
    end

    context 'organization user' do
      before { org.add_user(user) }
      it_behaves_like :read_only
    end

    context 'user in a different organization (defensive)' do
      before do
        different_organization = VCAP::CloudController::Models::Organization.make
        different_organization.add_user(user)
      end

      it_behaves_like :no_access
    end

    context 'manager in a different organization (defensive)' do
      before do
        different_organization = VCAP::CloudController::Models::Organization.make
        different_organization.add_manager(user)
      end

      it_behaves_like :no_access
    end

    context 'a user that isnt logged in (defensive)' do
      let(:user) { nil }
      let(:roles) { double(:roles, :admin? => false, :none? => true, :present => false) }
      it_behaves_like :no_access
    end
  end
end