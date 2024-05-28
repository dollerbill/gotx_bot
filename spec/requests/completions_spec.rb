# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Completions', type: :request do
  include_context 'Auth Helper'

  let(:completion) { create(:completion) }
  let(:nomination) { completion.nomination }

  describe 'GET /index' do
    subject { get nomination_completions_path(nomination) }

    it_behaves_like 'unauthorized'

    context 'a nomination with completions' do
      it 'renders nominations completions' do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(completion.game.preferred_name)
        expect(response.body).to include('1 completion for Grandia')
      end
    end

    context 'a nomination with no completions' do
      let(:nomination) { create(:nomination) }

      it 'renders a warning' do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(completion.game.preferred_name)
        expect(response.body).to include('No completions')
      end
    end
  end

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

  describe 'PATCH /update' do
    let(:atts) { { completion: { rpg_achievements: true } } }

    subject { patch completion_path(completion), params: { completion: { rpg_achievements: true } } }

    before { allow_any_instance_of(ActionDispatch::Request).to receive(:referer).and_return("/nominations/#{completion.nomination.id}/completions") }

    it_behaves_like 'unauthorized'

    context 'with rpg nominations' do
      let(:completion) { create(:completion, :rpg) }

      context 'with valid attributes' do
        it 'updates the record' do
          subject
          expect(completion.reload.rpg_achievements).to eq(true)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to "/nominations/#{completion.nomination.id}/completions"
          follow_redirect!
          expect(response.body).to include('Achievements successfully recorded.')
        end
      end

      context 'with invalid attributes' do
        before { allow_any_instance_of(Completion).to receive(:update).and_return(false) }

        it 'fails to update' do
          subject
          expect(completion.reload.rpg_achievements).to eq(false)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to "/nominations/#{completion.nomination.id}/completions"
          follow_redirect!
          expect(response.body).to include('Error updating achievements.')
        end
      end
    end

    context 'with non-rpg nominations' do
      it 'fails to update' do
        subject
        expect(completion.reload.rpg_achievements).to eq(false)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to "/nominations/#{completion.nomination.id}/completions"
        follow_redirect!
        expect(response.body).to include('Error updating achievements.')
      end
    end
  end
end
