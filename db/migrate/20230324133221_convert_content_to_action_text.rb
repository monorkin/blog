# frozen_string_literal: true

class ConvertContentToActionText < ActiveRecord::Migration[7.0]
  def up
    if ActiveStorage::Current.url_options.blank?
      url_opts = Rails.application.routes.default_url_options
      ActiveStorage::Current.url_options = {
        host: url_opts[:host],
        protocol: url_opts[:protocol] || url_opts[:scheme],
        port: url_opts[:port]
      }
    end

    rename_column :articles, :content, :old_content

    Article.all.each do |article|
      content = article.content.tap(&:save!)

      attachment_map = {}
      Article::Attachment.where(article_id: article.slug_id).each do |attachment|
        begin
          blob = ActiveStorage::Blob.create_and_upload!(
            io: attachment.attachment.to_io,
            filename: attachment.attachment_data&.dig("metadata", "filename"),
            content_type: attachment.attachment_data&.dig("metadata", "mime_type"),
            identify: false
          )

          attachment_map[attachment.id] = ActiveStorage::Attachment.find(
            ActiveStorage::Attachment.insert_all!(
              [
                name: "embeds",
                blob_id: blob.id,
                record_id: content.id,
                record_type: content.class.name
              ],
              returning: [:id],
              record_timestamps: true
            ).to_a.flatten.first.dig("id")
          )
        rescue Shrine::FileNotFound
          # The file doesn't exist so we ignore it
        end
      end

      content.update!(
        body: Nokogiri
        .HTML(article.html_content.to_html)
        .tap do |doc|
          doc
            .css("action-text-attachment")
            .each do |node|
              attachment = attachment_map[node["legacy-attachment-id"]]
              next if attachment.blank?

              caption = node["alt"] || node["title"]

              node.attributes.each do |name, _|
                node.delete(name)
              end

              attachment.to_rich_text_attributes.each do |key, value|
                node[key.to_s.gsub("_", "-")] = value&.to_s
              end
              node["url"] = Rails.application.routes.url_helpers.rails_storage_redirect_url(attachment.blob)
              node["caption"] = caption if caption.present?
            end
          title = doc.css("h1").first
          title.remove if title
        end.to_s
      )
    end
  end

  def down
    rename_column :articles, :old_content, :content
    execute "TRUNCATE TABLE active_storage_attachments;"
    execute "TRUNCATE TABLE active_storage_blobs CASCADE;"
    execute "TRUNCATE TABLE action_text_rich_texts;"
  end
end
