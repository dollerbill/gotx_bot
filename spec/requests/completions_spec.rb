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

  describe 'DELETE /destroy' do
    let(:completion) { create(:completion) }

    subject { delete completion_path(completion) }

    context 'when unauthorized' do
      it_behaves_like 'unauthorized'
    end

    context 'for a gotm game' do
      let(:streak) { create(:streak, :active, user: completion.user) }

      it 'deletes the completion' do
        expect { subject }.to change { Completion.count }
          .by(-1)
          .and change { completion.user.reload.earned_points }
          .by(-1)
          .and change { streak.reload.streak_count }
          .by(-1)
        expect(response).to redirect_to(user_path(completion.user))
      end
    end

    context 'for a non gotm game' do
      let(:completion) { create(:completion, nomination: create(:nomination, :goty)) }

      it 'does not update the streak' do
        expect(Streaks::Decrease).to_not receive(:call)
        subject
        expect { completion.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
