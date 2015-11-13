@user ||= nil

json.array! @topics, partial: 'topic', as: :topic, user: @user
