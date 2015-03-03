module Aguser

  def self.encrypted_password(password, salt)
    unless Rails.configuration.x.auth.secret.nil?
      string_to_hash = password + Rails.configuration.x.auth.secret + salt
    else
      Rails.logger.warn 'Could not find value for "config.x.auth.secret" in the Rails config. It is highly recommended you set a unique value for this in your environment!'
      string_to_hash = password + salt
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
          record.errors[:password_confirmation] << 'Password confirmation doesn\t match the password given'
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
        validates_presence_of :user_name
        validates_uniqueness_of :user_name, scope: self.user_scope
        validates_presence_of :password_confirmation, :password, :if => :new_record?
        validates_with PasswordMatchValidator


        include Aguser::ActsAsUser::LocalInstanceMethods
        self.send :include, Aguser::ActsAsUser::AuthenticatedClassMethods
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

      def self.authenticate(user_name, password)
        user = self.where(verify_scope(self.user_scope).merge!(user_name: user_name)).first
        if user
          expected_password = Aguser::encrypted_password(password, user.salt)
          if user.hashed_password != expected_password or user.disabled
            user = nil
          end
        end
        user
      end

    end
  end
end

ActiveRecord::Base.send :include, Aguser::ActsAsUser
