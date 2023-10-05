# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Themes', type: :request do
  include_context 'Auth Helper'

  let(:theme) { create(:theme) }
  let!(:themes) { [theme] }

  describe 'GET /index' do
    subject { get themes_path }

    it_behaves_like 'unauthorized'

    it 'renders themes data' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(theme.id.to_s)
      expect(response.body).to include(theme.title)
    end
  end

  describe 'GET /show' do
    subject { get theme_path(theme.id) }

    it_behaves_like 'unauthorized'

    it 'displays a users data' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(theme.title)
      expect(response.body).to include(theme.description)
    end
  end

  describe 'GET /new' do
    subject { get theme_path(theme.id) }

    it_behaves_like 'unauthorized'

    it 'displays a users data' do
      subject
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /edit' do
    subject { get edit_theme_path(theme.id) }

    it_behaves_like 'unauthorized'

    it 'fetches the edit form for the correct record' do
      subject
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(theme.title)
    end
  end

  describe 'POST /create' do
    let(:atts) { { theme: attributes_for(:theme) } }

    subject { post themes_path(atts) }

    it_behaves_like 'unauthorized'

    context 'with valid atts' do
      it 'creates a theme' do
        expect { subject }.to change { Theme.count }.by(1)
        expect(response).to redirect_to(theme_path(Theme.last))
      end
    end

    context 'with invalid atts' do
      before { allow_any_instance_of(Theme).to receive(:save).and_return(false) }

      it 'does not create a record' do
        theme_count = Theme.count
        subject
        expect(Theme.count).to eq(theme_count)
      end
    end
  end

  describe 'PATCH /update' do
    let(:atts) { { theme: { title: 'A different title' } } }

    subject { patch theme_path(theme, atts) }

    it_behaves_like 'unauthorized'

    context 'with valid attributes' do
      it 'updates the record' do
        subject
        expect(theme.reload.title).to eq('A different title')
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(theme_path(theme))
      end
    end

    context 'with invalid attributes' do
      before { allow_any_instance_of(Theme).to receive(:update).and_return(false) }

      it 'fails to update' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
