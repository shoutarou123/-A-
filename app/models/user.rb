class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  
  attr_accessor :remember_token
  before_save { self.email = email.downcase }

  validates :name,  presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true    
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :affiliation, length: { maximum: 20 }
  validates :employee_number, length: { minimum: 3 }, allow_blank: true
  validates :uid, length: { minimum: 3 }, allow_blank: true
  
  validates :designated_work_start_time, presence: true
  validates :designated_work_end_time, presence: true
  

  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end
  
   # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄します。
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def self.import(file)
    CSV.foreach(file.path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
      next if row["email"].nil? # emailカラムがNULLの場合はスキップする

      #nameが見つからなければ新しく作成
      user = find_by(name: row["name"]) || new
      # CSVからデータを取得し、設定する
      user.attributes = row.to_hash.slice(*updatable_attributes)
      user.save
    end
  end

  def count_pending_overtime_requests
    self.attendances.where(approval_status: "申請中").count
  end

  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["name", "email", "affiliation", "employee_number", "uid", "basic_time", "designated_work_start_time",
    "designated_work_end_time", "superior", "admin", "password", "password_confirmation"]
  end

  def self.generate_csv(attendances)
    CSV.generate(headers: true) do |csv|
      csv << ['日付', '曜日', '出社', '退社', '備考']  
       attendances.each do |attendance|

        csv << [
          attendance.worked_on.strftime('%m/%d'),  # 日付を指定のフォーマットに変換
          attendance.worked_on.strftime('%a'),    # 曜日を取得
          (attendance.chg_status == '申請中' ? '' : attendance.started_at&.strftime('%H:%M')),  # 出社時間を取得または'申請中'
          (attendance.chg_status == '申請中' ? '' : attendance.finished_at&.strftime('%H:%M')), # 退社時間を取得または'申請中'
          attendance.note
        ]
      end
    end
  end
end

# ok