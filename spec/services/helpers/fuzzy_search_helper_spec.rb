# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Helpers::FuzzySearchHelper do
  describe '#set_search_limit' do
    let(:test_class) do
      Class.new do
        include Helpers::FuzzySearchHelper
      end
    end

    subject { test_class.new.set_search_limit }

    it 'sets the search limit' do
      expect(ActiveRecord::Base.connection).to receive(:execute).with('SELECT set_limit(0.25);')

      subject
    end
  end
end
