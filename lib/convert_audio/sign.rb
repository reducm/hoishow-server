module ConvertAudio
  module Sign
    def self.md5_sign(operator_name, operator_passwd, params)
      params_string = params.sort.to_h.map{|key, value| "#{key.to_s}#{value}"}.join('')
      sign_string = "#{operator_name}#{params_string}#{Digest::MD5.hexdigest(operator_passwd)}"
      Digest::MD5.hexdigest(sign_string)
    end
  end
end
