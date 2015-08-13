module Aguser

  def self.encrypted_password(password, salt)
    if Rails.configuration.x.auth.secret.nil?
      Rails.logger.warn 'Could not find value for "config.x.auth.secret" in the Rails config. It is highly recommended you set a unique value for this in your environment!'
      string_to_hash = password + salt
    else
      string_to_hash = password + Rails.configuration.x.auth.secret + salt
    end
    Digest::SHA1.hexdigest(string_to_hash)
  end

  module ActsAsUser
    extend ActiveSupport::Concern

    included do
    end

    class PasswordMatchValidator < ActiveModel::Validator

      def validate(record)
        if (record.password or record.password_confirmation) and record.password != record.password_confirmation
          record.errors[:password_confirmation] << 'Password confirmation doesn\'t match the password given'
        end
      end

    end

    module ClassMethods

      # Initial class method do make any ActiveRecord::Base a user.
      def acts_as_user(options = {})

        # Class attribute set up for storing the scope for the user's uniqueness
        cattr_accessor :user_scope
        self.user_scope = options[:scope] || []

        # Set up accessor for password confirmation.
        attr_accessor :password_confirmation

        # Set up validation
        unless options[:optional] == true
          validates :user_name, presence: true
          validates :password_confirmation, presence: { if: :new_record? }
          validates :password, presence: { if: :new_record? }
        end
        validates :user_name, length: { minimum: 4, allow_nil: true, allow_blank: false }, uniqueness: {scope: self.user_scope, allow_nil: true, allow_blank: false}
        validates_with PasswordMatchValidator

        include Aguser::ActsAsUser::LocalInstanceMethods
        self.class.send :include, Aguser::ActsAsUser::AuthenticatedClassMethods
      end
    end

    module LocalInstanceMethods

      def password
        @password
      end

      def password=(pwd)
        @password = pwd
        return if pwd.blank?
        create_new_salt
        self.hashed_password = Aguser::encrypted_password(self.password, self.salt)
      end

    private

      def create_new_salt
        self.salt = self.object_id.to_s + rand.to_s
      end

    end

    module AuthenticatedClassMethods

      def authenticate(user_name, password, scope = {})
        if user_name.blank? or password.blank?
          nil
        else
          user = self.where(verify_scope(scope).merge(user_name: user_name)).first
          if user
            expected_password = Aguser::encrypted_password(password, user.salt)
            if user.hashed_password != expected_password or (user.respond_to? :disabled and user.disabled)
              user = nil
            end
          end
          user
        end
      end

      # Verifies the keys for the scope defined in the class.
      def verify_scope(scope)
        self.user_scope.each do |sym|
          raise RuntimeError, "Expected to be passed a scope containing the key '#{sym.to_s}'" unless scope.has_key? sym
        end
        scope
      end

    end
  end
end

ActiveRecord::Base.send :include, Aguser::ActsAsUser
