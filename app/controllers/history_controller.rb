# Copyright (C) 2021 colpari, https://colpari.com

class HistoryController < ApplicationController
  #include CreatesTicketArticles
  #include ClonesTicketArticleAttachments
  #include ChecksUserAttributesByCurrentUserPermission
  #include TicketStats
  include History::Assets

  # FIXME: check permissions
  prepend_before_action -> { authorize! }, only: %i[create selector import_example import_start ticket_customer ticket_history ticket_related ticket_recent ticket_merge ticket_split]
  prepend_before_action :authentication_check

  # GET /api/v1/history/:object_type/:attribute/after/:time
  def by_type_attr_time

    error = nil

    if not params[:object_type] or not type_id = History::Object.lookup(name: params[:object_type])
      error = "Invalid object type '#{params[:object_type]}'"
    end

    if not params[:attribute] or not attr_id = History::Attribute.lookup(name: params[:attribute])
      error = "Invalid attribute type '#{params[:attribute]}'"
    end

    raise error if error

    data = History.where(history_object_id: type_id, history_attribute_id: attr_id)
                  .where("updated_at > ?", DateTime.parse(params[:time]))

    render json: self.postprocess(data)
  end

  def postprocess(data)
    return data.map(&:attributes).each do |entry|
      if entry['history_attribute_id']
        entry['attribute'] = History::Attribute.lookup(id: entry.delete('history_attribute_id'))&.name
      end

      if entry['created_by_id']
        entry['user'] = User.lookup(id: entry.delete('created_by_id'))&.login
      end
    end
  end

end
