# coding: utf-8
module UmengMsg
  module Params

    def self.push_params(platform, title: "", content: "", file_id: "", subject_type: "", subject_id: "", targets: "", start_time: "", expire_time: "", description: "", activity_name: "")
      params = {
        appkey:          UmengMsg.appkey(platform),
        timestamp:       Time.now.to_i.to_s,
        type:            "customizedcast",
        alias_type:      "user_id",
        file_id:         file_id,
        production_mode: UmengMessageSetting["production_mode"],
        description:     title,
        policy:          {
                            start_time: start_time,
                            expire_time: expire_time,
                            out_biz_no: file_id
                         }
      }

      # 平台参数
      if platform == 'ios'
        params = {
          payload: {
            aps:      { alert: content },
            subject_type: subject_type,
            subject_id: subject_id,
            title:    activity_name,
            description: description
          }
        }.merge(params)
      else
        params = {
          payload: {
            display_type: "notification",
            body: {
              ticker:     title,
              title:      title,
              text:       content,
              after_open: "go_app",
            },
            extra: {
              subject_type:   subject_type,
              subject_id:     subject_id,
              title:    activity_name,
              description: description
            }
          }
        }.merge(params)
      end

      params.to_json
    end

    def self.upload_params(platform, content)
      params = {
        appkey:    UmengMsg.appkey(platform),
        timestamp: Time.now.to_i.to_s,
        content:   content
      }.to_json
    end

    def self.check_params(platform, task_id)
      params = {
        appkey:    UmengMsg.appkey(platform),
        timestamp: Time.now.to_i.to_s,
        task_id:   task_id
      }.to_json
    end

  end
end
