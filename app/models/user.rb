class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :statuses, class_name: Status.name
  has_many :tours, class_name: Tour.name
  before_save {self.email = email.downcase}
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers:
    [:facebook, :google_oauth2]
  belongs_to :business, optional: true
  has_one :image, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :image, reject_if: proc {|attributes|
    attributes['image_link'].blank?}
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :conversations, :foreign_key => :sender_id

  enum role: { admin: 1, user: 2, business: 3 }
  enum status: { block: 1, unblock: 2 }
  before_create :set_default_role, :if => :new_record?
  before_create :set_default_status, :if => :new_record?

  def set_default_status
    self.role ||= :unblock
  end

  def set_default_role
    self.role ||= :user
  end

  def self.new_with_session params, session
    super.tap do |user|
      if data = session["devise.facebook_data"] &&
        session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.from_omniauth auth
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
    end
  end
end
