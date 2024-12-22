# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nominations', type: :request do
  include_context 'Auth Helper'

  let(:nomination) { create(:nomination) }
  let!(:nominations) { [nomination] }

  describe 'GET /index' do
    subject { get nominations_path }

    it_behaves_like 'unauthorized'

    it 'renders nomination data' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(nomination.game.preferred_name)
    end
  end

  describe 'GET /current_nominations' do
    let(:gotm1) { create(:nomination) }
    let(:gotm2) { create(:nomination) }
    let(:rpg1) { create(:nomination, :rpg) }
    let(:rpg2) { create(:nomination, :rpg) }
    let(:current) { Nomination.where(id: [gotm1.id, gotm2.id, rpg1, rpg2]) }

    subject { get current_nominations_path }

    it_behaves_like 'unauthorized'

    before { allow(Nomination).to receive(:current_nominations).and_return(current) }

    it 'returns the current nominations' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('GotM Nominations: 2').and include('RPGotQ Nominations: 2')
    end
  end

  describe 'GET /show' do
    subject { get nomination_path(nomination.id) }

    it_behaves_like 'unauthorized'

    it 'displays a nominations data' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(nomination.game.preferred_name)
    end
  end

  describe 'GET /new' do
    subject { get nomination_path(nomination.id) }

    it_behaves_like 'unauthorized'

    it 'displays a games data' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /edit' do
    subject { get edit_nomination_path(nomination.id) }

    it_behaves_like 'unauthorized'

    it 'fetches the edit form for the correct record' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(nomination.description)
    end
  end

  describe 'PATCH /update' do
    let(:atts) { { nomination: { description: 'Grandia best game ever' } } }

    subject { patch nomination_path(nomination, atts) }

    it_behaves_like 'unauthorized'

    context 'with valid attributes' do
      it 'updates the record' do
        subject
        expect(nomination.reload.description).to eq('Grandia best game ever')
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(nomination_path(nomination))
      end
    end

    context 'with invalid attributes' do
      before { allow_any_instance_of(Nomination).to receive(:update).and_return(false) }

      it 'fails to update' do
        subject
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PATCH /select_winner' do
    subject { patch select_winner_nomination_path(nomination) }

    it_behaves_like 'unauthorized'

    it 'updates the nomination as a winner' do
      subject
      expect(nomination.reload.winner).to eq(true)
      expect(response).to redirect_to(current_nominations_path)
    end
  end

  describe 'DELETE /destroy' do
    let(:nomination) { create(:nomination) }

    subject { delete nomination_path(nomination) }

    it_behaves_like 'unauthorized'

    it 'deletes the nomination' do
      expect { subject }.to change { Nomination.count }.by(-1)
      expect(response).to redirect_to(nominations_path)
    end
  end

  describe 'GET /winners' do
    subject { get winners_nominations_path, params: { month: '05', year: '2023' } }

    it_behaves_like 'unauthorized'

    context 'with valid month and year parameters' do
      let!(:winner1) { create(:nomination, :winner, theme: create(:theme, creation_date: Date.new(2023, 5, 1))) }
      let!(:winner2) { create(:nomination, :winner, theme: create(:theme, creation_date: Date.new(2023, 5, 15))) }

      it 'assigns winners for the specified month and year' do
        subject
        expect(response).to have_http_status(:ok)
        expect(response.body).to match("<td><a href=\"/nominations/#{winner1.id}\">")
          .and match("<td><a href=\"/nominations/#{winner2.id}\">")
      end
    end

    context 'without date params' do
      it 'return an empty array' do
        get winners_nominations_path
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include('<td><a href="/nominations/">')
      end
    end
  end
end
