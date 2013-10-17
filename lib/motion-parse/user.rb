module MotionParse
  class User < Base
    attribute :username, :password, :email

    def initialize
      super(PFUser.user)
    end

    def self.current
      if PFUser.currentUser
        new.tap do |u|
          u.parse_object = PFUser.currentUser
        end
      else
        return nil
      end
    end

    def signUp
      parse_object = PFUser.new()
      parse_object.username = username
      parse_object.password = password
      parse_object.email = email
      self.attributes.each do |field|
        parse_object[field[0]] = field[1] if field[1] && !parse_object.respond_to?("#{field[0]}=")
      end
      if parse_object.signUpInBackground()
        self.tap do |u|
          u.parse_object = PFUser.currentUser
        end
      else
        return nil
      end
    end

    def self.login(username, password)
      if PFUser.logInWithUsername(username, password: password)
        new.tap do |u|
          u.parse_object = PFUser.currentUser
        end
      else
        return nil
      end
    end

    def self.login_in_background(username, password)
      if PFUser.logInWithUsernameInBackground(username, password: password)
        new.tap do |u|
          u.parse_object = PFUser.currentUser
        end
      else
        return nil
      end
    end

    def logout
      PFUser.logOut
    end

    def self.request_password_reset(email)
      PFUser.requestPasswordResetForEmail(email)
    end

  end
end
