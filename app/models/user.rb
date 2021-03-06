class User < ActiveRecord::Base
  has_many :devices
  
  has_many :logs, :through => :devices
  has_many :contacts, :through => :devices
  has_many :messages, :through => :devices
  has_many :locations, :through => :devices
  has_many :apps, :through => :devices
  
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :username, :presence => true, uniqueness: { case_sensitive: false }, :length => { :in => 3..55}
  validates :email, :presence => true, uniqueness: { case_sensitive: false }, :format => EMAIL_REGEX
  validates :password, :confirmation => true
  validates_length_of :password, :in => 3..20, :on => :create
  validates :status, presence: true

  before_save :encrypt_password
  after_save :clear_password

  def password=(password_value)
    @password = password_value
  end

  def password
    @password
  end

  def encrypt_password
    if password.present?
      self.salt = BCrypt::Engine.generate_salt
      self.encrypted_password = BCrypt::Engine.hash_secret(password, salt)
    end
  end

  def clear_password
    if password.present?
      self.password = nil
    end
  end

  def self.authenticate(username_or_email="", login_password="")
    if  EMAIL_REGEX.match(username_or_email)    
      user = User.find_by_email(username_or_email)
    else
      user = User.find_by_username(username_or_email)
    end
    if user && user.status==1 && user.match_password(login_password)
      return user
    else
      return false
    end
  end   
  
  def match_password(login_password="")
    encrypted_password == BCrypt::Engine.hash_secret(login_password, salt)
  end
end
