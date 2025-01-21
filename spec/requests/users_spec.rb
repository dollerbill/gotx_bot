# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :request do
  include_context 'Auth Helper'

  let(:user) { create(:user, :legend, current_points: 3, premium_points: 107.0) }
  let!(:users) { [user] }

  describe 'GET /index' do
    subject { get users_path }

    it_behaves_like 'unauthorized'

    context 'authorized' do
      it 'renders users data' do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(user.id.to_s)
        expect(response.body).to include(user.name)
      end
    end
  end

  describe 'GET /show' do
    subject { get user_path(user.id) }

    it 'displays a users data' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.name)
      expect(response.body).to include(user.premium_subscriber.capitalize)
    end
  end

  describe 'GET /edit' do
    subject { get edit_user_path(user.id) }

    it 'fetches the edit form for the correct record' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.name)
      expect(response.body).to include(user.premium_points.to_s)
    end
  end

  describe 'PATCH /update' do
    let(:atts) { { user: { current_points: 45 } } }

    subject { patch user_path(user, atts) }

    it_behaves_like 'unauthorized'

    context 'authorized' do
      before { allow_any_instance_of(Users::Update).to receive(:notify).and_return('Updated!') }

      context 'with valid attributes' do
        it 'updates the record' do
          expect { subject }.to change { user.reload.current_points }.from(3).to(45)
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(user_path(user))
        end
      end

      context 'with same attributes' do
        let(:atts) { { user: { premium_points: 107.0 } } }

        it 'does not update' do
          subject
          expect(response).to redirect_to(edit_user_path(user))
        end
      end

      context 'with invalid attributes' do
        let(:atts) { { user: { current_points: 'Name' } } }

        before { allow_any_instance_of(User).to receive(:save).and_return(false) }

        it 'fails to update' do
          subject
          expect(response).to redirect_to(edit_user_path(user))
        end
      end
    end
  end

  describe 'POST /redeem_points' do
    let(:atts) { { points: 3 } }

    subject { post redeem_points_user_path(user, atts) }

    it_behaves_like 'unauthorized'

    context 'authorized' do
      context 'with points available' do
        it 'updates the user record' do
          expect { subject }.to change { user.reload.redeemed_points }
            .from(0).to(3)
            .and change { user.current_points }.from(3).to(0)
          expect(response).to redirect_to(user_path(user))
          expect(flash[:notice]).to eq('Points successfully redeemed.')
        end
      end

      context 'with too few points available' do
        before { user.update(current_points: 1) }

        it 'returns error and does not update points' do
          expect { subject }.not_to change { user.reload.current_points }
          expect(response).to redirect_to(user_path(user))
          expect(flash[:alert]).to eq('User does not have enough points to redeem.')
        end
      end
    end
  end

  describe 'GET /previous_finishers' do
    let(:gotm_user) { user }
    let(:rpg_user) { build(:user) }
    let(:goty_user) { build(:user) }
    let(:retro_user) { build(:user) }
    let!(:gotm) { create(:completion, user: gotm_user) }
    let!(:goty) { create(:completion, :goty, user: goty_user) }
    let!(:retro) { create(:completion, :retro, user: retro_user) }
    let!(:rpg) { create(:completion, :rpg, user: rpg_user) }

    subject { get previous_finishers_path }

    it_behaves_like 'unauthorized'
    context 'authorized' do
      before do
        Theme.gotm.update_all(creation_date: Date.current.last_month.beginning_of_month)
        Theme.goty.update_all(creation_date: Date.current.last_year.beginning_of_year)
        Theme.retro.update_all(creation_date: Date.current.last_week.beginning_of_week)
        Theme.rpg.update_all(creation_date: Date.current.last_quarter.beginning_of_quarter)
      end

      context 'defaults to gotm' do
        it 'returns a list of the months previous finishers' do
          subject
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(gotm_user.name)
        end
      end

      %w[retro rpg goty].each do |type|
        context 'specifying type' do
          subject { get previous_finishers_path, params: { type: } }

          it 'returns a list of finishers for the queried type' do
            subject
            expect(response).to have_http_status(:ok)
            expect(response.body).to include(send("#{type}_user").name)
          end
        end
      end
    end
  end
end
