# frozen_string_literal: true

module Users
  class FindOrCreate
    attr_reader :user

    def self.call(member)
      new(member).call
    end

    def initialize(member)
      @member = member
    end

    def call
      if (user = User.find_by(discord_id: @member.id) || User.find_by(name: @member.name))
        user
      else
        create_user
      end
    end

    private

    def create_user
      User.create(name: @member.name, discord_id: @member.id)
    end
  end
end
