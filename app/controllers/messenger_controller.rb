# frozen_string_literal: true

class MessengerController < ApplicationController

  def create
    params.delete(:member_id) if params[:member_id].blank?

    Gotx::Messenger.send_message(params[:channel], params[:message], member_id: params[:member_id])
    redirect_to root_path, notice: 'Message sent!'
  end
end
