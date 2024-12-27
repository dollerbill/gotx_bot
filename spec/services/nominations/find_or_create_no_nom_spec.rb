# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nominations::FindOrCreateNoNom do
  let(:game)   { create(:game) }
  let!(:user)  { create(:user, id: 12) }
  let!(:theme) { create(:theme, id: 225) }

  subject { described_class.(game) }

  describe 'call' do
    context 'with no existing nomination' do
      it 'creates a new nomination' do
        expect { subject }.to change(Nomination, :count).by(1)
      end
    end

    context 'with an existing nomination for the game' do
      let!(:existing_nomination) { create(:nomination, game:, theme:) }

      it 'returns the nomination' do
        expect { subject }.not_to change(Nomination, :count)
        expect(subject).to eq(existing_nomination)
      end
    end
  end
end
