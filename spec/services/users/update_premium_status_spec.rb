# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::UpdatePremiumStatus do
  let(:user) { build(:user) }
  let(:status) { 'supporter' }

  subject { described_class.(user, status) }

  describe 'call' do
    context 'with no existing membership' do
      it 'updates membership status' do
        expect { subject }.to change { user.premium_subscriber }
          .from(nil).to(status)
      end
    end

    context 'with existing membership' do
      let(:user) { build(:user, :legend) }
      it 'updates membership status' do
        expect { subject }.to change { user.premium_subscriber }
          .from('legend').to(status)
      end
    end

    context 'improper enum values' do
      let(:status) { 'patreon' }

      it 'does not update' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
