# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Completions', type: :request do
  include_context 'Auth Helper'
  describe 'POST /create' do
    let(:user) { create(:user) }
    let(:nomination) { create(:nomination) }
    let(:atts) { { user_id: user.id, nomination_id: nomination.id } }

    subject { post completions_path(atts) }

    it_behaves_like 'unauthorized'

    context 'with valid atts' do
      it 'creates a completion' do
        expect { subject }.to change { Completion.count }.by(1).and change { user.reload.earned_points }.by(1)
        expect(user.reload.streaks.count).to eq(0)
        expect(response).to redirect_to(nomination_path(Completion.last.nomination))
      end
    end

    context 'with invalid atts' do
      before { allow_any_instance_of(Completion).to receive(:save!).and_return(false) }

      it 'does not create a record' do
        expect { subject }.to_not change { Completion.count }
      end
    end
  end
end
