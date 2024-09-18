module ApplicationHelper
  def encrypt_data(data)
    cipher = OpenSSL::Cipher::AES.new(128, :CBC)
    cipher.encrypt
    key = cipher.random_key
    iv = cipher.random_iv
    encrypted = cipher.update(data) + cipher.final
    Base64.encode64(encrypted) # Encode the encrypted data to make it easier to display
  end
end
